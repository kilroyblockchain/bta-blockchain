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

//ProjectVersion struct -- Main Package
type ProjectVersionChaincode struct {
	contractapi.Contract
}

// Asset Struct for storing data
type ProjectVersion struct {
	Id                 string `json:"id"`
	VersionName        string `json:"versionName"`
	LogFilePath        string `json:"logFilePath"`
	LogFileVersion     string `json:"logFileVersion"`
	LogFileBCHash      string `json:"logFileBCHash"`
	VersionModel       string `json:"versionModel"`
	NoteBookVersion    string `json:"noteBookVersion"`
	TestDataSets       string `json:"testDataSets"`
	TestDatasetBCHash  string `json:"testDatasetBCHash"`
	TrainDataSets      string `json:"trainDataSets"`
	TrainDatasetBCHash string `json:"trainDatasetBCHash"`
	Artifacts          string `json:"artifacts"`
	CodeVersion        string `json:"codeVersion"`
	CodeRepo           string `json:"codeRepo"`
	Comment            string `json:"comment"`
	VersionStatus      string `json:"versionStatus"`
	Status             bool   `json:"status"`
	Project            string `json:"project"`
	RecordDate         string `json:"recordDate"`
	EntryUser          string `json:"entryUser,omitempty"`
}

// Project Version History Struct for project history response
type ProjectVersionHistory struct {
	TxId           string         `json:"txId,omitempty"`
	IsDeleted      bool           `json:"isDeleted"`
	ProjectVersion ProjectVersion `json:"projectVersion,omitempty"`
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

// StoreProjectVersion Function creates new state on the ledger with given params value.
func (p *ProjectVersionChaincode) StoreProjectVersion(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {

	// Initialize New Logger
	log := NewLogger("StoreProjectVersion")
	log.Info(params)

	projectVersion := new(ProjectVersion)

	// Convert parameter data into projectVersion struct
	err := json.Unmarshal([]byte(params), &projectVersion)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON Marshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	// Validation ends

	// Get ProjectVersion State by given projectVersion id from ledger
	getProjectVersionAsBytes, err := ctx.GetStub().GetState(projectVersion.Id)
	if err != nil {
		log.Error(errors.Wrap(err, "ProjectVersion Fetch Failed"))
		return Error("ProjectVersion Fetch Failed", BAD_REQUEST)
	}
	// Returns error is projectVersion with the projectVersion id already exists

	var responseMessage string = "ProjectVersion Created"
	if len(getProjectVersionAsBytes) > 0 {
		responseMessage = "ProjectVersion Updated"
	}

	// Get Transaction UTC Date Time string
	txDateTime, err := GetTxDateTimeString(ctx)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to get transaction time stamp"))
		return Error("Failed to get transaction time stamp", INTERNAL_SERVER_ERROR)
	}
	projectVersion.RecordDate = txDateTime

	// Convert ProjectVersion Struct into bytes
	projectVersionAsBytes, err := json.Marshal(projectVersion)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON Marshal Failed"))
		return Error("JSON Marshal Failed", BAD_REQUEST)
	}

	// Store projectVersion state on ledger
	err = ctx.GetStub().PutState(projectVersion.Id, projectVersionAsBytes)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to Create ProjectVersion"))
		return Error("Failed to Create ProjectVersion", INTERNAL_SERVER_ERROR)
	}

	// Return projectVersion create success message with projectVersion data
	return SuccessResponse(responseMessage, projectVersion), nil
}

// StoreProjectVersionBatch Function creates new state on the ledger with given params value.
func (p *ProjectVersionChaincode) StoreProjectVersionBatch(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {

	// Initialize New Logger
	log := NewLogger("StoreProjectVersion")
	log.Info(params)

	projectVersionList := []ProjectVersion{}

	// Convert parameter data into projectVersion projectVersionList
	err := json.Unmarshal([]byte(params), &projectVersionList)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON Marshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	for i := 0; i < len(projectVersionList); i++ {
		// Get Transaction UTC Date Time string
		txDateTime, err := GetTxDateTimeString(ctx)
		if err != nil {
			log.Error(errors.Wrap(err, "Failed to get transaction time stamp"))
			return Error("Failed to get transaction time stamp", INTERNAL_SERVER_ERROR)
		}
		projectVersionList[i].RecordDate = txDateTime

		// Convert ProjectVersion Struct into bytes
		projectVersionAsBytes, err := json.Marshal(projectVersionList[i])
		if err != nil {
			log.Error(errors.Wrap(err, "JSON Marshal Failed"))
			return Error("JSON Marshal Failed", BAD_REQUEST)
		}

		// Store projectVersion state on ledger
		err = ctx.GetStub().PutState(projectVersionList[i].Id, projectVersionAsBytes)
		if err != nil {
			log.Error(errors.Wrap(err, "Failed to Create ProjectVersion"))
			return Error("Failed to Create ProjectVersion", INTERNAL_SERVER_ERROR)
		}
	}

	// Return projectVersion create success message with projectVersion data
	return SuccessResponse("ProjectVersion Created", projectVersionList), nil
}

// GetProjectVersion Function returns projectVersion state by projectVersion Id
func (p *ProjectVersionChaincode) GetProjectVersion(ctx contractapi.TransactionContextInterface, projectVersionId string) (*Response, error) {
	log := NewLogger("GetProjectVersion")
	if len(projectVersionId) == 0 {
		log.Error("ProjectVersion Id Not found", projectVersionId)
		return Error("Id must not be empty", BAD_REQUEST)
	}

	projectVersionAsBytes, err := ctx.GetStub().GetState(projectVersionId)
	if err != nil {
		log.Error(errors.Wrap(err, "ProjectVersion Fetch Failed"))
		return Error("ProjectVersion Fetch Failed", BAD_REQUEST)
	}

	if len(projectVersionAsBytes) == 0 {
		log.Error("ProjectVersion Not Found " + projectVersionId)
		return Error("ProjectVersion Not Found", NOT_FOUND)
	}

	projectVersion := ProjectVersion{}

	json.Unmarshal(projectVersionAsBytes, &projectVersion)

	return SuccessResponse("ProjectVersion Fetched", projectVersion), nil
}

// GetProjectVersionHistory function returns history of the projectVersion by projectVersion id
func (p *ProjectVersionChaincode) GetProjectVersionHistory(ctx contractapi.TransactionContextInterface, projectVersionId string) (*Response, error) {

	const functionName = "GetProjectVersionHistory"

	// Initialize Logger
	log := NewLogger(functionName)

	if len(projectVersionId) == 0 {
		log.Error("ProjectVersion Id Not found: " + projectVersionId)
		return Error("Id must not be empty", BAD_REQUEST)
	}

	// Get Education History By Composite Key
	resultsIterator, err := ctx.GetStub().GetHistoryForKey(projectVersionId)
	if err != nil {
		log.Error("Error fetching blockchain history: " + err.Error())
		return Error("Error fetching blockchain history", INTERNAL_SERVER_ERROR)
	}
	defer resultsIterator.Close()

	projectVersionList, err := ResultIteratorHistoryToProjectVersionList(resultsIterator)

	if err != nil {
		log.Error(err.Error())
		return Error(err.Error(), INTERNAL_SERVER_ERROR)
	}

	return SuccessResponse("ProjectVersion History Fetch Success", projectVersionList), nil

}

// ResultIteratorToProjectVersionList function to map result iterator response from ledger to projectVersion list struct
func ResultIteratorHistoryToProjectVersionList(resultsIterator shim.HistoryQueryIteratorInterface) ([]ProjectVersionHistory, error) {

	projectVersionHistoryList := []ProjectVersionHistory{}

	for resultsIterator.HasNext() {
		projectVersionHistory := ProjectVersionHistory{}
		queryResponse, err := resultsIterator.Next()
		projectVersionHistory.TxId = queryResponse.TxId
		if err != nil {
			return nil, errors.Wrap(err, "Cannot Iterate")
		}
		projectVersionHistory.TxId = queryResponse.TxId
		if queryResponse.IsDelete {
			projectVersionHistory.IsDeleted = queryResponse.IsDelete
		} else {
			err = json.Unmarshal(queryResponse.Value, &projectVersionHistory.ProjectVersion)
			if err != nil {
				return nil, errors.Wrap(err, "Unmarshal result iterator")
			}
			projectVersionHistory.IsDeleted = false
		}
		projectVersionHistoryList = append(projectVersionHistoryList, projectVersionHistory)
	}
	return projectVersionHistoryList, nil
}

// GetTxDateTimeString function gets transaction date time and returns UTC date time string
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
func (p *ProjectVersionChaincode) startChaincode() *Response {

	// Create a new Smart Contract
	chaincode, err := contractapi.NewChaincode(new(ProjectVersionChaincode))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract Asset Management")
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting new Smart Contract ProjectVersion")
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
	projectVersionChaincode := &ProjectVersionChaincode{}
	projectVersionChaincode.startChaincode()
}
