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

//ModelArtifactChaincode struct -- Main Package
type ModelArtifactChaincode struct {
	contractapi.Contract
}

// ModelArtifact Struct
type ModelArtifact struct {
	ModelArtifactName   string       `json:"modelArtifactName"`
	ModelArtifactBcHash string       `json:"modelArtifactBcHash"`
	ModelVersion        ModelVersion `json:"modelVersion"`
	Project             Project      `json:"project"`
	RecordDate          string       `json:"recordDate"`
	EntryUser           string       `json:"entryUser"`
	CreatorMSP          string       `json:"creatorMSP"`
}

type ModelVersion struct {
	Id          string `json:"id"`
	VersionName string `json:"versionName"`
}

type Project struct {
	Id          string `json:"id"`
	ProjectName string `json:"projectName"`
}

// ModelArtifactHistory Struct for ModelArtifact history response
type ModelArtifactHistory struct {
	TxId          string        `json:"txId,omitempty"`
	IsDeleted     bool          `json:"isDeleted"`
	ModelArtifact ModelArtifact `json:"modelArtifact,omitempty"`
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

// StoreModelArtifact Function updates existing ModelArtifact state if id already exists and  with given params value.
func (p *ModelArtifactChaincode) StoreModelArtifact(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {

	// Initialize New Logger
	log := NewLogger("StoreModelArtifact")
	log.Info(params)

	// Initialize empty ModelArtifact struct
	modelArtifact := new(ModelArtifact)

	// Convert parameter data into modelArtifact struct
	err := json.Unmarshal([]byte(params), &modelArtifact)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON UnMarshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	index := "project~version~artifact"
	modelArtifactId, err := ctx.GetStub().CreateCompositeKey(index, []string{modelArtifact.Project.Id, modelArtifact.ModelVersion.Id, modelArtifact.ModelArtifactName})

	// Get ModelArtifact State from ledger by given modelArtifactId.
	getModelArtifactAsBytes, err := ctx.GetStub().GetState(modelArtifactId)
	if err != nil {
		log.Error(errors.Wrap(err, "ModelArtifact Fetch Failed"))
		return Error("ModelArtifact Fetch Failed", BAD_REQUEST)
	}

	var responseMessage string = "ModelArtifact Created"
	if len(getModelArtifactAsBytes) > 0 {
		responseMessage = "ModelArtifact Updated"
	}

	// Get Transaction UTC Date Time string
	txDateTime, err := GetTxDateTimeString(ctx)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to get transaction time stamp"))
		return Error("Failed to get transaction time stamp", INTERNAL_SERVER_ERROR)
	}
	modelArtifact.RecordDate = txDateTime
	modelArtifact.CreatorMSP = GetCreatorMSP(ctx)
	// Convert ModelArtifact Struct into bytes
	modelArtifactAsBytes, err := json.Marshal(modelArtifact)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON Marshal Failed"))
		return Error("JSON Marshal Failed", BAD_REQUEST)
	}

	// Store modelArtifact state on ledger
	err = ctx.GetStub().PutState(modelArtifactId, modelArtifactAsBytes)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to Store ModelArtifact"))
		return Error("Failed to Store ModelArtifact", INTERNAL_SERVER_ERROR)
	}

	// Return modelArtifact store success message with modelArtifact data
	return SuccessResponse(responseMessage, modelArtifact), nil
}

// GetModelArtifact Function returns modelArtifact state by modelArtifact Id
func (p *ModelArtifactChaincode) GetModelArtifact(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {
	log := NewLogger("GetModelArtifact")

	// Initialize empty ModelArtifact struct
	modelArtifact := new(ModelArtifact)

	// Convert parameter data into modelArtifact struct
	err := json.Unmarshal([]byte(params), &modelArtifact)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON UnMarshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	index := "project~version~artifact"
	modelArtifactId, err := ctx.GetStub().CreateCompositeKey(index, []string{modelArtifact.Project.Id, modelArtifact.ModelVersion.Id, modelArtifact.ModelArtifactName})

	if err != nil {
		log.Error(errors.Wrap(err, "Failed to create composite key"))
		return Error("Composite key create failed", BAD_REQUEST)
	}

	// Get ModelArtifact State from ledger by given modelArtifactId.
	getModelArtifactAsBytes, err := ctx.GetStub().GetState(modelArtifactId)
	if err != nil {
		log.Error(errors.Wrap(err, "ModelArtifact Fetch Failed"))
		return Error("ModelArtifact Fetch Failed", BAD_REQUEST)
	}

	if len(getModelArtifactAsBytes) == 0 {
		log.Error("ModelArtifact Not Found " + modelArtifactId)
		return Error("ModelArtifact Not Found", NOT_FOUND)
	}

	json.Unmarshal(getModelArtifactAsBytes, &modelArtifact)

	return SuccessResponse("ModelArtifact Fetched", modelArtifact), nil
}

// GetModelArtifactHistory function returns history of the modelArtifact by modelArtifact id
func (p *ModelArtifactChaincode) GetModelArtifactHistory(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {

	const functionName = "GetModelArtifactHistory"

	// Initialize Logger
	log := NewLogger(functionName)

	// Initialize empty ModelArtifact struct
	modelArtifact := new(ModelArtifact)

	// Convert parameter data into modelArtifact struct
	err := json.Unmarshal([]byte(params), &modelArtifact)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON UnMarshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	index := "project~version~artifact"
	modelArtifactId, err := ctx.GetStub().CreateCompositeKey(index, []string{modelArtifact.Project.Id, modelArtifact.ModelVersion.Id, modelArtifact.ModelArtifactName})

	if err != nil {
		log.Error(errors.Wrap(err, "Failed to create composite key"))
		return Error("Composite key create failed", BAD_REQUEST)
	}

	// Get AI Model History By Id Key
	resultsIterator, err := ctx.GetStub().GetHistoryForKey(modelArtifactId)
	if err != nil {
		log.Error("Error fetching blockchain history: " + err.Error())
		return Error("Error fetching blockchain history", INTERNAL_SERVER_ERROR)
	}
	defer resultsIterator.Close()

	modelArtifactList, err := ResultIteratorHistoryToModelArtifactList(resultsIterator)

	if err != nil {
		log.Error(err.Error())
		return Error(err.Error(), INTERNAL_SERVER_ERROR)
	}

	return SuccessResponse("ModelArtifact History Fetch Success", modelArtifactList), nil

}

// ResultIteratorToModelArtifactList function to map result iterator response from ledger to modelArtifact list struct
func ResultIteratorHistoryToModelArtifactList(resultsIterator shim.HistoryQueryIteratorInterface) ([]ModelArtifactHistory, error) {

	modelArtifactHistoryList := []ModelArtifactHistory{}

	for resultsIterator.HasNext() {
		modelArtifactHistory := ModelArtifactHistory{}
		queryResponse, err := resultsIterator.Next()
		modelArtifactHistory.TxId = queryResponse.TxId
		if err != nil {
			return nil, errors.Wrap(err, "Cannot Iterate")
		}
		modelArtifactHistory.TxId = queryResponse.TxId
		if queryResponse.IsDelete {
			modelArtifactHistory.IsDeleted = queryResponse.IsDelete
		} else {
			err = json.Unmarshal(queryResponse.Value, &modelArtifactHistory.ModelArtifact)
			if err != nil {
				return nil, errors.Wrap(err, "Unmarshal result iterator")
			}
			modelArtifactHistory.IsDeleted = false
		}
		modelArtifactHistoryList = append(modelArtifactHistoryList, modelArtifactHistory)
	}
	return modelArtifactHistoryList, nil
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
func (p *ModelArtifactChaincode) startChaincode() *Response {

	// Create a new Smart Contract
	chaincode, err := contractapi.NewChaincode(new(ModelArtifactChaincode))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract Asset Management")
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting new Smart Contract ModelArtifact")
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
	modelArtifactChaincode := &ModelArtifactChaincode{}
	modelArtifactChaincode.startChaincode()
}
