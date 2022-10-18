package main

import (
	"encoding/json"

	"github.com/pkg/errors"

	"fmt"
	"time"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"

	"github.com/sirupsen/logrus"
)

// MainLogger struct
type MainLogger struct {
	*logrus.Logger
	FunctionName string
}

//ModelVersionChaincode struct -- Main Package
type ModelVersionChaincode struct {
	contractapi.Contract
}

// ModelVersion Struct
type ModelVersion struct {
	Id                 string  `json:"id"`
	VersionName        string  `json:"versionName"`
	LogFilePath        string  `json:"logFilePath"`
	LogFileBCHash      string  `json:"logFileBCHash"`
	NoteBookVersion    string  `json:"noteBookVersion"`
	TestDataSetsUrl    string  `json:"testDataSetsUrl"`
	TestDatasetBCHash  string  `json:"testDatasetBCHash"`
	TrainDataSetsUrl   string  `json:"trainDataSetsUrl"`
	TrainDatasetBCHash string  `json:"trainDatasetBCHash"`
	AIModelUrl         string  `json:"aiModelUrl"`
	AIModelBCHash      string  `json:"aiModelBCHash"`
	CodeVersion        string  `json:"codeVersion"`
	CodeRepo           string  `json:"codeRepo"`
	Comment            string  `json:"comment"`
	VersionStatus      string  `json:"versionStatus"`
	Status             bool    `json:"status"`
	Project            Project `json:"project"`
	RecordDate         string  `json:"recordDate"`
	EntryUser          string  `json:"entryUser"`
	CreatorMSP         string  `json:"creatorMSP"`
}

const (
	PENDING       = "Pending"
	REVIEW        = "Reviewing"
	REVIEW_PASSED = "Review Passed"
	REVIEW_FAILED = "Review Failed"
	PRODUCTION    = "Production"
	DEPLOYED      = "Deployed"
	MONITORING    = "Monitoring"
	COMPLETE      = "Complete"
	DRAFT         = "Draft"
)

type Project struct {
	Id          string `json:"id"`
	ProjectName string `json:"projectName"`
}

// ModelVersionHistory Struct for ModelVersion history response
type ModelVersionHistory struct {
	TxId         string       `json:"txId,omitempty"`
	IsDeleted    bool         `json:"isDeleted"`
	ModelVersion ModelVersion `json:"modelVersion,omitempty"`
}

// Response Struct
type Response struct {
	StatusCode int32       `json:"statusCode,omitempty"`
	Message    string      `json:"message,omitempty"`
	Result     interface{} `json:"result,omitempty" metadata:",optional"`
}

const (
	// OK constant - status code less than 400, endorser will endorse it.
	// OK means init or invoke successfully.
	OK = 200

	// BAD_REQUEST constant - error specifically for use when request params does not meet the requirement.
	BAD_REQUEST = 400

	// NOT_FOUND constant - error when requested resource could not be found but may be available in the future
	NOT_FOUND = 404

	// INTERNAL_SERVER_ERROR constant - a generic error message, given when an unexpected condition was encountered and no more specific message is suitable
	INTERNAL_SERVER_ERROR = 500

	// CONFLICT constant - error when the request could not be processed because of conflict in the current state of the resource.
	CONFLICT = 409
)

// StoreModelVersion Function updates existing ModelVersion state if id already exists and  with given params value.
func (p *ModelVersionChaincode) StoreModelVersion(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {

	// Initialize New Logger
	log := NewLogger("StoreModelVersion")
	log.Info(params)

	// Initialize empty ModelVersion struct
	modelVersion := new(ModelVersion)

	// Convert parameter data into modelVersion struct
	err := json.Unmarshal([]byte(params), &modelVersion)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON UnMarshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	// Get ModelVersion State from ledger by given modelVersionId.
	getModelVersionAsBytes, err := ctx.GetStub().GetState(modelVersion.Id)
	if err != nil {
		log.Error(errors.Wrap(err, "ModelVersion Fetch Failed"))
		return Error("ModelVersion Fetch Failed", BAD_REQUEST)
	}

	var responseMessage string = "ModelVersion Created"
	if len(getModelVersionAsBytes) > 0 {
		responseMessage = "ModelVersion Updated"
	}

	// Get Transaction UTC Date Time string
	txDateTime, err := GetTxDateTimeString(ctx)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to get transaction time stamp"))
		return Error("Failed to get transaction time stamp", INTERNAL_SERVER_ERROR)
	}
	modelVersion.RecordDate = txDateTime
	modelVersion.CreatorMSP = GetCreatorMSP(ctx)
	// Convert ModelVersion Struct into bytes
	modelVersionAsBytes, err := json.Marshal(modelVersion)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON Marshal Failed"))
		return Error("JSON Marshal Failed", BAD_REQUEST)
	}

	// Store modelVersion state on ledger
	err = ctx.GetStub().PutState(modelVersion.Id, modelVersionAsBytes)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to Store ModelVersion"))
		return Error("Failed to Store ModelVersion", INTERNAL_SERVER_ERROR)
	}

	// Return modelVersion store success message with modelVersion data
	return SuccessResponse(responseMessage, modelVersion), nil
}

// GetModelVersion Function returns modelVersion state by modelVersion Id
func (p *ModelVersionChaincode) GetModelVersion(ctx contractapi.TransactionContextInterface, modelVersionId string) (*Response, error) {
	log := NewLogger("GetModelVersion")
	if len(modelVersionId) == 0 {
		log.Error("ModelVersion Id Not found", modelVersionId)
		return Error("Id must not be empty", BAD_REQUEST)
	}

	modelVersionAsBytes, err := ctx.GetStub().GetState(modelVersionId)
	if err != nil {
		log.Error(errors.Wrap(err, "ModelVersion Fetch Failed"))
		return Error("ModelVersion Fetch Failed", BAD_REQUEST)
	}

	if len(modelVersionAsBytes) == 0 {
		log.Error("ModelVersion Not Found " + modelVersionId)
		return Error("ModelVersion Not Found", NOT_FOUND)
	}

	modelVersion := ModelVersion{}

	json.Unmarshal(modelVersionAsBytes, &modelVersion)

	return SuccessResponse("ModelVersion Fetched", modelVersion), nil
}

// GetModelVersionHistory function returns history of the modelVersion by modelVersion id
func (p *ModelVersionChaincode) GetModelVersionHistory(ctx contractapi.TransactionContextInterface, modelVersionId string) (*Response, error) {

	const functionName = "GetModelVersionHistory"

	// Initialize Logger
	log := NewLogger(functionName)

	if len(modelVersionId) == 0 {
		log.Error("ModelVersion Id Not found: " + modelVersionId)
		return Error("Id must not be empty", BAD_REQUEST)
	}

	// Get AI Model History By Id Key
	resultsIterator, err := ctx.GetStub().GetHistoryForKey(modelVersionId)
	if err != nil {
		log.Error("Error fetching blockchain history: " + err.Error())
		return Error("Error fetching blockchain history", INTERNAL_SERVER_ERROR)
	}
	defer resultsIterator.Close()

	modelVersionList, err := ResultIteratorHistoryToModelVersionList(resultsIterator)

	if err != nil {
		log.Error(err.Error())
		return Error(err.Error(), INTERNAL_SERVER_ERROR)
	}

	return SuccessResponse("ModelVersion History Fetch Success", modelVersionList), nil

}

// ResultIteratorToModelVersionList function to map result iterator response from ledger to modelVersion list struct
func ResultIteratorHistoryToModelVersionList(resultsIterator shim.HistoryQueryIteratorInterface) ([]ModelVersionHistory, error) {

	modelVersionHistoryList := []ModelVersionHistory{}

	for resultsIterator.HasNext() {
		modelVersionHistory := ModelVersionHistory{}
		queryResponse, err := resultsIterator.Next()
		modelVersionHistory.TxId = queryResponse.TxId
		if err != nil {
			return nil, errors.Wrap(err, "Cannot Iterate")
		}
		modelVersionHistory.TxId = queryResponse.TxId
		if queryResponse.IsDelete {
			modelVersionHistory.IsDeleted = queryResponse.IsDelete
		} else {
			err = json.Unmarshal(queryResponse.Value, &modelVersionHistory.ModelVersion)
			if err != nil {
				return nil, errors.Wrap(err, "Unmarshal result iterator")
			}
			modelVersionHistory.IsDeleted = false
		}
		modelVersionHistoryList = append(modelVersionHistoryList, modelVersionHistory)
	}
	return modelVersionHistoryList, nil
}

// GetTxDateTimeString function gets transaction timestamp and converts into UTC date time string
func GetTxDateTimeString(ctx contractapi.TransactionContextInterface) (string, error) {
	log := NewLogger("GetTxDateTimeString")
	currentDateTime, err := ctx.GetStub().GetTxTimestamp()
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to get transaction time stamp"))
		return "", err
	}
	unixTimeUTC := time.Unix(currentDateTime.Seconds, 0) //gives unix time stamp in utc
	return unixTimeUTC.Format(time.RFC3339), nil

}

func Error(errorMessage string, statusCode int32) (*Response, error) {
	marshalData, _ := json.Marshal(ErrorResponse(errorMessage, statusCode))
	return nil, fmt.Errorf(string(marshalData))
}

func GetCreatorMSP(ctx contractapi.TransactionContextInterface) string {
	mspId, _ := ctx.GetClientIdentity().GetMSPID()
	return mspId
}

// SuccessResponse
func SuccessResponse(message string, result interface{}) *Response {
	response := new(Response)
	response.Message = message
	response.Result = result
	response.StatusCode = OK
	return response
}

func ErrorResponse(message string, statusCode int32) *Response {
	response := new(Response)
	response.Message = message
	response.Result = nil
	response.StatusCode = statusCode
	return response

}

// StartChaincode Function
func (p *ModelVersionChaincode) startChaincode() *Response {

	// Create a new Smart Contract
	chaincode, err := contractapi.NewChaincode(new(ModelVersionChaincode))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract Asset Management")
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting new Smart Contract ModelVersion")
	}
	return SuccessResponse("Chaincode Started Successfully: AssetManagement", nil)
}

// Error function prints error logs on console with custom fields
func (m *MainLogger) Error(args ...interface{}) {
	m.WithFields(logrus.Fields{
		"functionName": m.FunctionName,
	}).Error(args...)
}

// Info function prints info logs on console with custom fields
func (m *MainLogger) Info(args ...interface{}) {
	m.WithFields(logrus.Fields{
		"functionName": m.FunctionName,
	}).Info(args...)
}

// NewLogger Function to create new logger
func NewLogger(functionName string) *MainLogger {
	baseLogger := logrus.New()
	standardLogger := &MainLogger{baseLogger, functionName}
	jsonFormat := &logrus.JSONFormatter{
		FieldMap: logrus.FieldMap{
			logrus.FieldKeyTime:  "timeStamp",
			logrus.FieldKeyLevel: "logLevel",
			logrus.FieldKeyMsg:   "message",
		},
	}
	standardLogger.Formatter = jsonFormat
	standardLogger.FunctionName = functionName
	return standardLogger
}

// main function
func main() {
	modelVersionChaincode := &ModelVersionChaincode{}
	modelVersionChaincode.startChaincode()
}
