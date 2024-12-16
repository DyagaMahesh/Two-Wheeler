package contracts

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// InsurancePolicy represents the structure of an insurance policy
type InsurancePolicy struct {
	PolicyID     string `json:"policyID"`
	PolicyHolder string `json:"policyHolder"`
	PolicyAmount string `json:"policyAmount"`
	PolicyType   string `json:"policyType"`
}

// InsurancePolicyContract manages the operations for insurance policies
type InsurancePolicyContract struct {
	contractapi.Contract
}

// CreateInsurancePolicy creates a new insurance policy
func (s *InsurancePolicyContract) CreateInsurancePolicy(ctx contractapi.TransactionContextInterface, policyID string, policyHolder string, policyAmount string, policyType string) error {
	policy := InsurancePolicy{
		PolicyID:     policyID,
		PolicyHolder: policyHolder,
		PolicyAmount: policyAmount,
		PolicyType:   policyType,
	}

	policyJSON, err := json.Marshal(policy)
	if err != nil {
		return fmt.Errorf("failed to marshal policy: %v", err)
	}

	return ctx.GetStub().PutState(policyID, policyJSON)
}

// ReadInsurancePolicy retrieves an insurance policy from the world state
func (s *InsurancePolicyContract) ReadInsurancePolicy(ctx contractapi.TransactionContextInterface, policyID string) (*InsurancePolicy, error) {
	policyJSON, err := ctx.GetStub().GetState(policyID)
	if err != nil {
		return nil, fmt.Errorf("failed to read policy %s: %v", policyID, err)
	}
	if policyJSON == nil {
		return nil, fmt.Errorf("policy %s does not exist", policyID)
	}

	var policy InsurancePolicy
	err = json.Unmarshal(policyJSON, &policy)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal policy JSON: %v", err)
	}

	return &policy, nil
}
