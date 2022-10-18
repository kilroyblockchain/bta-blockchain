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

//ModelExperimentChaincode struct -- Main Package
type ModelExperimentChaincode struct {
	contractapi.Contract
}

// ModelExperiment Struct
type ModelExperiment struct {
	ExperimentName   string       `json:"experimentName"`
	ExperimentBcHash string       `json:"experimentBcHash"`
	ModelVersion     ModelVersion `json:"modelVersion"`
	Project          Project      `json:"project"`
	RecordDate       string       `json:"recordDate"`
	EntryUser        string       `json:"entryUser"`
	CreatorMSP       string       `json:"creatorMSP"`
}

type ModelVersion struct {
	Id          string `json:"id"`
	VersionName string `json:"versionName"`
}

type Project struct {
	Id          string `json:"id"`
	ProjectName string `json:"projectName"`
}

// ModelExperimentHistory Struct for ModelExperiment history response
type ModelExperimentHistory struct {
	TxId            string          `json:"txId,omitempty"`
	IsDeleted       bool            `json:"isDeleted"`
	ModelExperiment ModelExperiment `json:"modelExperiment,omitempty"`
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

// StoreModelExperiment Function updates existing ModelExperiment state if id already exists and  with given params value.
func (p *ModelExperimentChaincode) StoreModelExperiment(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {

	// Initialize New Logger
	log := NewLogger("StoreModelExperiment")
	log.Info(params)

	// Initialize empty ModelExperiment struct
	modelExperiment := new(ModelExperiment)

	// Convert parameter data into modelExperiment struct
	err := json.Unmarshal([]byte(params), &modelExperiment)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON UnMarshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	index := "project~version~experiment"
	modelExperimentId, err := ctx.GetStub().CreateCompositeKey(index, []string{modelExperiment.Project.Id, modelExperiment.ModelVersion.Id, modelExperiment.ExperimentName})

	// Get ModelExperiment State from ledger by given modelExperimentId.
	getModelExperimentAsBytes, err := ctx.GetStub().GetState(modelExperimentId)
	if err != nil {
		log.Error(errors.Wrap(err, "ModelExperiment Fetch Failed"))
		return Error("ModelExperiment Fetch Failed", BAD_REQUEST)
	}

	var responseMessage string = "ModelExperiment Created"
	if len(getModelExperimentAsBytes) > 0 {
		responseMessage = "ModelExperiment Updated"
	}

	// Get Transaction UTC Date Time string
	txDateTime, err := GetTxDateTimeString(ctx)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to get transaction time stamp"))
		return Error("Failed to get transaction time stamp", INTERNAL_SERVER_ERROR)
	}
	modelExperiment.RecordDate = txDateTime
	modelExperiment.CreatorMSP = GetCreatorMSP(ctx)
	// Convert ModelExperiment Struct into bytes
	modelExperimentAsBytes, err := json.Marshal(modelExperiment)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON Marshal Failed"))
		return Error("JSON Marshal Failed", BAD_REQUEST)
	}

	// Store modelExperiment state on ledger
	err = ctx.GetStub().PutState(modelExperimentId, modelExperimentAsBytes)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to Store ModelExperiment"))
		return Error("Failed to Store ModelExperiment", INTERNAL_SERVER_ERROR)
	}

	// Return modelExperiment store success message with modelExperiment data
	return SuccessResponse(responseMessage, modelExperiment), nil
}

// GetModelExperiment Function returns modelExperiment state by modelExperiment Id
func (p *ModelExperimentChaincode) GetModelExperiment(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {
	log := NewLogger("GetModelExperiment")

	// Initialize empty ModelExperiment struct
	modelExperiment := new(ModelExperiment)

	// Convert parameter data into modelExperiment struct
	err := json.Unmarshal([]byte(params), &modelExperiment)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON UnMarshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	index := "project~version~experiment"
	modelExperimentId, err := ctx.GetStub().CreateCompositeKey(index, []string{modelExperiment.Project.Id, modelExperiment.ModelVersion.Id, modelExperiment.ExperimentName})

	if err != nil {
		log.Error(errors.Wrap(err, "Failed to create composite key"))
		return Error("Composite key create failed", BAD_REQUEST)
	}

	// Get ModelExperiment State from ledger by given modelExperimentId.
	getModelExperimentAsBytes, err := ctx.GetStub().GetState(modelExperimentId)
	if err != nil {
		log.Error(errors.Wrap(err, "ModelExperiment Fetch Failed"))
		return Error("ModelExperiment Fetch Failed", BAD_REQUEST)
	}

	if len(getModelExperimentAsBytes) == 0 {
		log.Error("ModelExperiment Not Found " + modelExperimentId)
		return Error("ModelExperiment Not Found", NOT_FOUND)
	}

	json.Unmarshal(getModelExperimentAsBytes, &modelExperiment)

	return SuccessResponse("ModelExperiment Fetched", modelExperiment), nil
}

// GetModelExperimentHistory function returns history of the modelExperiment by modelExperiment id
func (p *ModelExperimentChaincode) GetModelExperimentHistory(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {

	const functionName = "GetModelExperimentHistory"

	// Initialize Logger
	log := NewLogger(functionName)

	// Initialize empty ModelExperiment struct
	modelExperiment := new(ModelExperiment)

	// Convert parameter data into modelExperiment struct
	err := json.Unmarshal([]byte(params), &modelExperiment)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON UnMarshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	index := "project~version~experiment"
	modelExperimentId, err := ctx.GetStub().CreateCompositeKey(index, []string{modelExperiment.Project.Id, modelExperiment.ModelVersion.Id, modelExperiment.ExperimentName})

	if err != nil {
		log.Error(errors.Wrap(err, "Failed to create composite key"))
		return Error("Composite key create failed", BAD_REQUEST)
	}

	// Get AI Model History By Id Key
	resultsIterator, err := ctx.GetStub().GetHistoryForKey(modelExperimentId)
	if err != nil {
		log.Error("Error fetching blockchain history: " + err.Error())
		return Error("Error fetching blockchain history", INTERNAL_SERVER_ERROR)
	}
	defer resultsIterator.Close()

	modelExperimentList, err := ResultIteratorHistoryToModelExperimentList(resultsIterator)

	if err != nil {
		log.Error(err.Error())
		return Error(err.Error(), INTERNAL_SERVER_ERROR)
	}

	return SuccessResponse("ModelExperiment History Fetch Success", modelExperimentList), nil

}

// ResultIteratorToModelExperimentList function to map result iterator response from ledger to modelExperiment list struct
func ResultIteratorHistoryToModelExperimentList(resultsIterator shim.HistoryQueryIteratorInterface) ([]ModelExperimentHistory, error) {

	modelExperimentHistoryList := []ModelExperimentHistory{}

	for resultsIterator.HasNext() {
		modelExperimentHistory := ModelExperimentHistory{}
		queryResponse, err := resultsIterator.Next()
		modelExperimentHistory.TxId = queryResponse.TxId
		if err != nil {
			return nil, errors.Wrap(err, "Cannot Iterate")
		}
		modelExperimentHistory.TxId = queryResponse.TxId
		if queryResponse.IsDelete {
			modelExperimentHistory.IsDeleted = queryResponse.IsDelete
		} else {
			err = json.Unmarshal(queryResponse.Value, &modelExperimentHistory.ModelExperiment)
			if err != nil {
				return nil, errors.Wrap(err, "Unmarshal result iterator")
			}
			modelExperimentHistory.IsDeleted = false
		}
		modelExperimentHistoryList = append(modelExperimentHistoryList, modelExperimentHistory)
	}
	return modelExperimentHistoryList, nil
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
func (p *ModelExperimentChaincode) startChaincode() *Response {

	// Create a new Smart Contract
	chaincode, err := contractapi.NewChaincode(new(ModelExperimentChaincode))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract Asset Management")
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting new Smart Contract ModelExperiment")
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
	modelExperimentChaincode := &ModelExperimentChaincode{}
	modelExperimentChaincode.startChaincode()
}
