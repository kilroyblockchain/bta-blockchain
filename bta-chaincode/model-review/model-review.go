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

//ModelReviewChaincode struct -- Main Package
type ModelReviewChaincode struct {
	contractapi.Contract
}

type ModelReview struct {
	Id                     string           `json:"id"`
	DeployedUrl            string           `json:"deployedUrl,omitempty"`
	DeploymentInstruction  string           `json:"deploymentInstruction,omitempty"`
	ProductionURL          string           `json:"productionURL,omitempty"`
	ReviewDocuments        []ReviewDocument `json:"reviewDocuments,omitempty"`
	ReviewStatus           string           `json:"reviewStatus"`
	ReviewedModelVersionId string           `json:"reviewedModelVersionId,omitempty"`
	Ratings                string           `json:"ratings,omitempty"`
	Comment                string           `json:"comment,omitempty"`
	RecordDate             string           `json:"recordDate"`
	EntryUserDetail        EntryUserDetail  `json:"entryUserDetail"`
	CreatorMSP             string           `json:"creatorMSP"`
}

type ReviewDocument struct {
	DocUrl  string `json:"docUrl,omitempty"`
	DocName string `json:"docName,omitempty"`
}

type EntryUserDetail struct {
	EntryUser        string `json:"entryUser"`
	OrganizationUnit string `json:"organizationUnit"`
	Staffing         string `json:"staffing"`
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

// ModelReviewHistory Struct for ModelReview history response
type ModelReviewHistory struct {
	TxId        string      `json:"txId,omitempty"`
	IsDeleted   bool        `json:"isDeleted"`
	ModelReview ModelReview `json:"modelReview,omitempty"`
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

// ReviewModel Function updates existing ModelReview state if id already exists and  with given params value.
func (p *ModelReviewChaincode) ReviewModel(ctx contractapi.TransactionContextInterface, params string) (*Response, error) {

	// Initialize New Logger
	log := NewLogger("ReviewModel")
	log.Info(params)

	// Initialize empty ModelReview struct
	modelReview := new(ModelReview)

	// Convert parameter data into modelReview struct
	err := json.Unmarshal([]byte(params), &modelReview)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON UnMarshal Failed"))
		return Error("Invalid  JSON Format", BAD_REQUEST)
	}

	// Get Transaction UTC Date Time string
	txDateTime, err := GetTxDateTimeString(ctx)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to get transaction time stamp"))
		return Error("Failed to get transaction time stamp", INTERNAL_SERVER_ERROR)
	}
	modelReview.RecordDate = txDateTime
	modelReview.CreatorMSP = GetCreatorMSP(ctx)
	// Convert ModelReview Struct into bytes
	modelReviewAsBytes, err := json.Marshal(modelReview)
	if err != nil {
		log.Error(errors.Wrap(err, "JSON Marshal Failed"))
		return Error("JSON Marshal Failed", BAD_REQUEST)
	}

	// Store modelReview state on ledger
	err = ctx.GetStub().PutState(modelReview.Id, modelReviewAsBytes)
	if err != nil {
		log.Error(errors.Wrap(err, "Failed to Store ModelReview"))
		return Error("Failed to Store ModelReview", INTERNAL_SERVER_ERROR)
	}

	// Return modelReview store success message with modelReview data
	return SuccessResponse("Model Reviewed", modelReview), nil
}

// GetModelReview Function returns modelReview state by modelReview Id
func (p *ModelReviewChaincode) GetModelReview(ctx contractapi.TransactionContextInterface, modelReviewId string) (*Response, error) {
	log := NewLogger("GetModelReview")
	if len(modelReviewId) == 0 {
		log.Error("ModelReview Id Not found", modelReviewId)
		return Error("Id must not be empty", BAD_REQUEST)
	}

	modelReviewAsBytes, err := ctx.GetStub().GetState(modelReviewId)
	if err != nil {
		log.Error(errors.Wrap(err, "ModelReview Fetch Failed"))
		return Error("ModelReview Fetch Failed", BAD_REQUEST)
	}

	if len(modelReviewAsBytes) == 0 {
		log.Error("ModelReview Not Found " + modelReviewId)
		return Error("ModelReview Not Found", NOT_FOUND)
	}

	modelReview := ModelReview{}

	json.Unmarshal(modelReviewAsBytes, &modelReview)

	return SuccessResponse("ModelReview Fetched", modelReview), nil
}

// GetModelReviewHistory function returns history of the modelReview by modelReview id
func (p *ModelReviewChaincode) GetModelReviewHistory(ctx contractapi.TransactionContextInterface, modelReviewId string) (*Response, error) {

	const functionName = "GetModelReviewHistory"

	// Initialize Logger
	log := NewLogger(functionName)

	if len(modelReviewId) == 0 {
		log.Error("ModelReview Id Not found: " + modelReviewId)
		return Error("Id must not be empty", BAD_REQUEST)
	}

	// Get AI Model History By Id Key
	resultsIterator, err := ctx.GetStub().GetHistoryForKey(modelReviewId)
	if err != nil {
		log.Error(errors.Wrap(err, "Error fetching blockchain history: "))
		return Error("Error fetching blockchain history", INTERNAL_SERVER_ERROR)
	}
	defer resultsIterator.Close()

	modelReviewList, err := ResultIteratorHistoryToModelReviewList(resultsIterator)

	if err != nil {
		log.Error(err.Error())
		return Error(err.Error(), INTERNAL_SERVER_ERROR)
	}

	return SuccessResponse("ModelReview History Fetch Success", modelReviewList), nil

}

// ResultIteratorToModelReviewList function to map result iterator response from ledger to modelReview list struct
func ResultIteratorHistoryToModelReviewList(resultsIterator shim.HistoryQueryIteratorInterface) ([]ModelReviewHistory, error) {

	modelReviewHistoryList := []ModelReviewHistory{}

	for resultsIterator.HasNext() {
		modelReviewHistory := ModelReviewHistory{}
		queryResponse, err := resultsIterator.Next()
		modelReviewHistory.TxId = queryResponse.TxId
		if err != nil {
			return nil, errors.Wrap(err, "Cannot Iterate")
		}
		modelReviewHistory.TxId = queryResponse.TxId
		if queryResponse.IsDelete {
			modelReviewHistory.IsDeleted = queryResponse.IsDelete
		} else {
			err = json.Unmarshal(queryResponse.Value, &modelReviewHistory.ModelReview)
			if err != nil {
				return nil, errors.Wrap(err, "Unmarshal result iterator")
			}
			modelReviewHistory.IsDeleted = false
		}
		modelReviewHistoryList = append(modelReviewHistoryList, modelReviewHistory)
	}
	return modelReviewHistoryList, nil
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
func (p *ModelReviewChaincode) startChaincode() *Response {

	// Create a new Smart Contract
	chaincode, err := contractapi.NewChaincode(new(ModelReviewChaincode))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract Asset Management")
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting new Smart Contract ModelReview")
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
	modelReviewChaincode := &ModelReviewChaincode{}
	modelReviewChaincode.startChaincode()
}
