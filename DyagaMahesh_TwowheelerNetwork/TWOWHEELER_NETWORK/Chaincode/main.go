package main

import (
	"log"

	"twnauto/contracts"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	bikeContract := new(contracts.BikeContract)
	orderContarct := new(contracts.OrderContract)

	chaincode, err := contractapi.NewChaincode(bikeContract, orderContarct)

	if err != nil {
		log.Panicf("Could not create chaincode : %v", err)
	}

	err = chaincode.Start()

	if err != nil {
		log.Panicf("Failed to start chaincode : %v", err)
	}
}