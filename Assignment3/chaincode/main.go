package main

import (
	"fmt"
	"insurance/contracts"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	// Adjust this to your actual project path
)

// Main entry point for the chaincode
func main() {
	// Create a new chaincode
	chaincode, err := contractapi.NewChaincode(&contracts.InsurancePolicyContract{})
	if err != nil {
		fmt.Printf("Error creating chaincode: %s", err)
		return
	}

	// Start the chaincode
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincode: %s", err)
	}
}
