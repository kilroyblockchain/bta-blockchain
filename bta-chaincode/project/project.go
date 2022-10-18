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

//Project struct -- Main Package
type ProjectChaincode struct {
	contractapi.Contract
}

// Project Struct
type Project struct {
	Id            string         `json:"id"`
	Name          string         `json:"name"`
	Detail        string         `json:"detail"`
	Domain        string         `json:"domain"`
	Members       []string       `json:"members"`
	Status        bool           `json:"status"`
	ModelVersions []ModelVersion `json:"modelVersions"`
	PurposeDetail PurposeDetail  `json:"purposeDetail"`
	RecordDate    string         `json:"recordDate"`
	CreatedBy     string         `json:"createdBy"`
	EntryUser     string         `json:"entryUser"`
	CreatorMSP    string         `json:"creatorMSP"`
}

type ModelVersion struct {
	Id          string `json:"id"`
	VersionName string `json:"versionName"`
}

// Project History Struct for project history response
type ProjectHistory struct {
	TxId      string  `json:"txId,omitempty"`
	IsDeleted bool    `json:"isDeleted"`
	Project   Project `json:"project,omitempty"`
}

type PurposeDetail struct {
	Purpose string `json:"purpose,omitempty"`
	DocName string `json:"docName,omitempty"`
	DocUrl  string `json:"docUrl,omitempty"`
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

// StoreProject Function updates existing Project state if id already exists and  with given params value.
func (p *ProjectChaincode) StoreProject(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {
	// Initialize New Logger
	log := NewLogger("StoreProject")
	log.Info(params)

	project := new(Project)

	// Convert parameter data into project struct
	err := json.Unmarshal([]byte(params), &project)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON Marshal Failed"))
		return Error("JSON Marshal Failed", INTERNAL_SERVER_ERROR)
	}

	// Get Project State by given project id from ledger
	getProjectAsBytes, err := ctx.GetStub().GetState(project.Id)
	if err != nil {
		log.Error(errors.Wrap(err, "Project Fetch Failed"))
		return Error("Project Fetch Failed", BAD_REQUEST)
	}

	var responseMessage string = "Project Created"
	if len(getProjectAsBytes) > 0 {
		responseMessage = "Project Updated"
	}

	// Get Transaction UTC Date Time string
	txDateTime, err := GetTxDateTimeString(ctx)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to get transaction time stamp"))
		return Error("Failed to get transaction time stamp", INTERNAL_SERVER_ERROR)
	}
	project.RecordDate = txDateTime
	mspId, _ := ctx.GetClientIdentity().GetMSPID()
	project.CreatorMSP = mspId

	// Convert Project Struct into bytes
	projectAsBytes, err := json.Marshal(project)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON Marshal Failed"))
		return Error("JSON Marshal Failed", BAD_REQUEST)
	}

	// Store project state on ledger
	err = ctx.GetStub().PutState(project.Id, projectAsBytes)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to Create Project"))
		return Error("Failed to Create Project", INTERNAL_SERVER_ERROR)
	}

	// Return project store success message with project data
	return SuccessResponse(responseMessage, project), nil
}

// GetProject Function returns project state by project Id
func (p *ProjectChaincode) GetProject(ctx contractapi.TransactionContextInterface, projectId string) (*Response, error) {
	log := NewLogger("GetProject")
	if len(projectId) == 0 {
		log.Error("Project Id Not found", projectId)
		return Error("Id must not be empty", BAD_REQUEST)
	}

	projectAsBytes, err := ctx.GetStub().GetState(projectId)
	if err != nil {
		log.Error(errors.Wrap(err, "Project Fetch Failed"))
		return Error("Project Fetch Failed", BAD_REQUEST)
	}

	if len(projectAsBytes) == 0 {
		log.Error("Project Not Found " + projectId)
		return Error("Project Not Found", NOT_FOUND)
	}

	project := Project{}

	json.Unmarshal(projectAsBytes, &project)

	return SuccessResponse("Project Fetched", project), nil
}

// GetProjectHistory function returns history of the project by project id
func (p *ProjectChaincode) GetProjectHistory(ctx contractapi.TransactionContextInterface, projectId string) (*Response, error) {

	const functionName = "GetProjectHistory"

	// Initialize Logger
	log := NewLogger(functionName)

	if len(projectId) == 0 {
		log.Error("Project Id Not found: " + projectId)
		return Error("Id must not be empty", BAD_REQUEST)
	}

	// Get Education History By Composite Key
	resultsIterator, err := ctx.GetStub().GetHistoryForKey(projectId)
	if err != nil {
		log.Error("Error fetching blockchain history: " + err.Error())
		return Error("Error fetching blockchain history", INTERNAL_SERVER_ERROR)
	}
	defer resultsIterator.Close()

	projectHistoryList, err := ResultIteratorToProjectList(resultsIterator)

	if err != nil {
		log.Error(err.Error())
		return Error(err.Error(), INTERNAL_SERVER_ERROR)
	}

	return SuccessResponse("Project History Fetch Success", projectHistoryList), nil

}

// DeleteProject function deletes the state from the blockchain
func (p *ProjectChaincode) DeleteProject(ctx contractapi.TransactionContextInterface, projectId string) (*Response, error) {

	const functionName = "DeleteProject"

	// Initialize Logger
	log := NewLogger(functionName)

	if len(projectId) == 0 {
		log.Error("Project Id Not found: " + projectId)
		return Error("Id must not be empty", BAD_REQUEST)
	}

	// Get Education History By Composite Key
	err := ctx.GetStub().DelState(projectId)
	if err != nil {
		log.Error("Error deleting project state: " + err.Error())
		return Error("Error deleting project state", INTERNAL_SERVER_ERROR)
	}

	return SuccessResponse("Project State Deleted", nil), nil

}

// ResultIteratorToProjectList function to map result iterator response from ledger to project list struct
func ResultIteratorToProjectList(resultsIterator shim.HistoryQueryIteratorInterface) ([]ProjectHistory, error) {

	projectHistoryList := []ProjectHistory{}

	for resultsIterator.HasNext() {
		projectHistory := ProjectHistory{}
		queryResponse, err := resultsIterator.Next()
		projectHistory.TxId = queryResponse.TxId
		if err != nil {
			return nil, errors.Wrap(err, "Cannot Iterate")
		}
		projectHistory.TxId = queryResponse.TxId
		if queryResponse.IsDelete {
			projectHistory.IsDeleted = queryResponse.IsDelete
		} else {
			err = json.Unmarshal(queryResponse.Value, &projectHistory.Project)
			if err != nil {
				return nil, errors.Wrap(err, "Unmarshal result iterator")
			}
			projectHistory.IsDeleted = false
		}
		projectHistoryList = append(projectHistoryList, projectHistory)
	}
	return projectHistoryList, nil

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
func (p *ProjectChaincode) startChaincode() *Response {

	// Create a new Smart Contract
	chaincode, err := contractapi.NewChaincode(new(ProjectChaincode))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract Project")
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting new Smart Contract Project")
	}
	return SuccessResponse("Chaincode Started Successfully: Project", nil)
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
	projectChaincode := &ProjectChaincode{}
	projectChaincode.startChaincode()
}
