package contracts

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// AccidentRecord represents the structure of an accident record
type AccidentRecord struct {
	RecordID  string `json:"recordID"`
	AccidentDate string `json:"accidentDate"`
	Location  string `json:"location"`
	Severity  string `json:"severity"`
}

// AccidentRecordContract manages the operations for accident records
type AccidentRecordContract struct {
	contractapi.Contract
}

// CreateAccidentRecord creates a new accident record
func (s *AccidentRecordContract) CreateAccidentRecord(ctx contractapi.TransactionContextInterface, recordID string, accidentDate string, location string, severity string) error {
	record := AccidentRecord{
		RecordID:   recordID,
		AccidentDate: accidentDate,
		Location:  location,
		Severity:  severity,
	}

	recordJSON, err := json.Marshal(record)
	if err != nil {
		return fmt.Errorf("failed to marshal record: %v", err)
	}

	return ctx.GetStub().PutState(recordID, recordJSON)
}

// ReadAccidentRecord retrieves an accident record from the world state
func (s *AccidentRecordContract) ReadAccidentRecord(ctx contractapi.TransactionContextInterface, recordID string) (*AccidentRecord, error) {
	recordJSON, err := ctx.GetStub().GetState(recordID)
	if err != nil {
		return nil, fmt.Errorf("failed to read record %s: %v", recordID, err)
	}
	if recordJSON == nil {
		return nil, fmt.Errorf("record %s does not exist", recordID)
	}

	var record AccidentRecord
	err = json.Unmarshal(recordJSON, &record)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal record JSON: %v", err)
	}

	return &record, nil
}
