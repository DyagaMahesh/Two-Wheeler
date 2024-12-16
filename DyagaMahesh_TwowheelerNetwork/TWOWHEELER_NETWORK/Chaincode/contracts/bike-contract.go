package contracts

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// BikeContract contract for managing CRUD for Bike
type BikeContract struct {
	contractapi.Contract
}
type PaginatedQueryResult struct {
	Records             []*Bike `json:"records"`
	FetchedRecordsCount int32  `json:"fetchedRecordsCount"`
	Bookmark            string `json:"bookmark"`
}

type HistoryQueryResult struct {
	Record    *Bike   `json:"record"`
	TxId      string `json:"txId"`
	Timestamp string `json:"timestamp"`
	IsDelete  bool   `json:"isDelete"`
}

type Bike struct {
	AssetType         string `json:"assetType"`
	BikeId             string `json:"bikeId"`
	Color             string `json:"color"`
	DateOfManufacture string `json:"dateOfManufacture"`
	Make              string `json:"make"`
	Model             string `json:"model"`
	OwnedBy           string `json:"ownedBy"`
	Status            string `json:"status"`
}

type EventData struct{
	Type string
	Model string
}


// BikeExists returns true when asset with given ID exists in world state
func (b *BikeContract) BikeExists(ctx contractapi.TransactionContextInterface, bikeID string) (bool, error) {
	data, err := ctx.GetStub().GetState(bikeID)

	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}
	return data != nil, nil
}

// CreateBike creates a new instance of Bike
func (b *BikeContract) CreateBike(ctx contractapi.TransactionContextInterface, bikeID string, make string, model string, color string, manufacturerName string, dateOfManufacture string) (string, error) {
	clientOrgID, err := ctx.GetClientIdentity().GetMSPID()

	if err != nil {
		return "", fmt.Errorf("could not fetch client identity. %s", err)
	}

	// if clientOrgID == "Org1MSP" {
	if clientOrgID == "BikeManufacturerMSP" {
		// if clientOrgID == "bikemanufacturer-auto-com" {

		exists, err := b.BikeExists(ctx, bikeID)
		if err != nil {
			return "", fmt.Errorf("could not fetch the details from world state.%s", err)
		} else if exists {
			return "", fmt.Errorf("the bike, %s already exists", bikeID)
		}

		bike := Bike{
			AssetType:         "bike",
			BikeId:             bikeID,
			Color:             color,
			DateOfManufacture: dateOfManufacture,
			Make:              make,
			Model:             model,
			OwnedBy:           manufacturerName,
			Status:            "In Factory",
		}

		fmt.Println("Create bike data ======= ", bike)
		bytes, _ := json.Marshal(bike)

		err = ctx.GetStub().PutState(bikeID, bytes)
		if err != nil {
			return "", fmt.Errorf("could not create bike. %s", err)
		} else {
			addBikeEventData := EventData{
				Type: "Bike creation",
				Model: model,
			}
			eventDataByte, _ := json.Marshal(addBikeEventData)
			ctx.GetStub().SetEvent("CreateBike",eventDataByte)

			
			return fmt.Sprintf("successfully added bike %v", bikeID), nil
		}

	} else {
		return "", fmt.Errorf("user under following MSPID: %v can't perform this action", clientOrgID)
	}
}

// ReadBike retrieves an instance of Bike from the world state
func (b *BikeContract) ReadBike(ctx contractapi.TransactionContextInterface, bikeID string) (*Bike, error) {

	bytes, err := ctx.GetStub().GetState(bikeID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if bytes == nil {
		return nil, fmt.Errorf("the bike %s does not exist", bikeID)
	}

	var bike Bike

	err = json.Unmarshal(bytes, &bike)

	if err != nil {
		return nil, fmt.Errorf("could not unmarshal world state data to type Bike")
	}

	return &bike, nil
}

// DeleteBike removes the instance of Bike from the world state
func (b *BikeContract) DeleteBike(ctx contractapi.TransactionContextInterface, bikeID string) (string, error) {

	clientOrgID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("could not fetch client identity. %s", err)
	}
	// if clientOrgID == "Org1MSP" {
	// if clientOrgID == "bikemanufacturer-auto-com" {
	if clientOrgID == "BikeManufacturerMSP" {

		exists, err := b.BikeExists(ctx, bikeID)
		if err != nil {
			return "", fmt.Errorf("%s", err)
		} else if !exists {
			return "", fmt.Errorf("the bike, %s does not exist", bikeID)
		}

		err = ctx.GetStub().DelState(bikeID)
		if err != nil {
			return "", err
		} else {
			return fmt.Sprintf("bike with id %v is deleted from the world state.", bikeID), nil
		}

	} else {
		return "", fmt.Errorf("user under following MSPID: %v can't perform this action", clientOrgID)
	}
}

func (b *BikeContract) GetBikesByRange(ctx contractapi.TransactionContextInterface, startKey, endKey string) ([]*Bike, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)
	if err != nil {
		return nil, fmt.Errorf("could not fetch the  data by range. %s", err)
	}
	defer resultsIterator.Close()

	return bikeResultIteratorFunction(resultsIterator)
}

func (b *BikeContract) GetAllBikes(ctx contractapi.TransactionContextInterface) ([]*Bike, error) {

	queryString := `{"selector":{"assetType":"bike"}, "sort":[{ "color": "desc"}]}`

	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, fmt.Errorf("could not fetch the query result. %s", err)
	}
	defer resultsIterator.Close()
	return bikeResultIteratorFunction(resultsIterator)
}

func bikeResultIteratorFunction(resultsIterator shim.StateQueryIteratorInterface) ([]*Bike, error) {
	var bikes []*Bike
	for resultsIterator.HasNext() {
		queryResult, err := resultsIterator.Next()
		if err != nil {
			return nil, fmt.Errorf("could not fetch the details of the result iterator. %s", err)
		}
		var bike Bike
		err = json.Unmarshal(queryResult.Value, &bike)
		if err != nil {
			return nil, fmt.Errorf("could not unmarshal the data. %s", err)
		}
		bikes = append(bikes, &bike)
	}

	return bikes, nil
}

func (b *BikeContract) GetBikeHistory(ctx contractapi.TransactionContextInterface, bikeID string) ([]*HistoryQueryResult, error) {

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(bikeID)
	if err != nil {
		return nil, fmt.Errorf("could not get the data. %s", err)
	}
	defer resultsIterator.Close()

	var records []*HistoryQueryResult
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return nil, fmt.Errorf("could not get the value of resultsIterator. %s", err)
		}

		var bike Bike
		if len(response.Value) > 0 {
			err = json.Unmarshal(response.Value, &bike)
			if err != nil {
				return nil, err
			}
		} else {
			bike = Bike{
				BikeId: bikeID,
			}
		}

		timestamp := response.Timestamp.AsTime()

		formattedTime := timestamp.Format(time.RFC1123)

		record := HistoryQueryResult{
			TxId:      response.TxId,
			Timestamp: formattedTime,
			Record:    &bike,
			IsDelete:  response.IsDelete,
		}
		records = append(records, &record)
	}

	return records, nil
}

func (b *BikeContract) GetBikesWithPagination(ctx contractapi.TransactionContextInterface, pageSize int32, bookmark string) (*PaginatedQueryResult, error) {

	queryString := `{"selector":{"assetType":"bike"}}`

	resultsIterator, responseMetadata, err := ctx.GetStub().GetQueryResultWithPagination(queryString, pageSize, bookmark)
	if err != nil {
		return nil, fmt.Errorf("could not get the bike records. %s", err)
	}
	defer resultsIterator.Close()

	bikes, err := bikeResultIteratorFunction(resultsIterator)
	if err != nil {
		return nil, fmt.Errorf("could not return the bike records %s", err)
	}

	return &PaginatedQueryResult{
		Records:             bikes,
		FetchedRecordsCount: responseMetadata.FetchedRecordsCount,
		Bookmark:            responseMetadata.Bookmark,
	}, nil
}

// GetMatchingOrders get matching orders for bike from the orders
func (b *BikeContract) GetMatchingOrders(ctx contractapi.TransactionContextInterface, bikeID string) ([]*Order, error) {

	bike, err := b.ReadBike(ctx, bikeID)
	if err != nil {
		return nil, fmt.Errorf("error reading bike %v", err)
	}
	queryString := fmt.Sprintf(`{"selector":{"assetType":"Order","make":"%s", "model": "%s", "color":"%s"}}`, bike.Make, bike.Model, bike.Color)
	resultsIterator, err := ctx.GetStub().GetPrivateDataQueryResult(collectionName, queryString)

	if err != nil {
		return nil, fmt.Errorf("could not get the data. %s", err)
	}
	defer resultsIterator.Close()

	return OrderResultIteratorFunction(resultsIterator)

}

// MatchOrder matches bike with matching order
func (b *BikeContract) MatchOrder(ctx contractapi.TransactionContextInterface, bikeID string, orderID string) (string, error) {
	clientOrgID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("could not fetch client identity. %s", err)
	}
	// if clientOrgID == "Org1MSP" {
	// if clientOrgID == "bikemanufacturer-auto-com" {
	if clientOrgID == "BikeManufacturerMSP" {
		bytes, err := ctx.GetStub().GetPrivateData(collectionName, orderID)
		if err != nil {
			return "", fmt.Errorf("could not get the private data: %s", err)
		}

		var order Order

		err = json.Unmarshal(bytes, &order)

		if err != nil {
			return "", fmt.Errorf("could not unmarshal the data. %s", err)
		}

		bike, err := b.ReadBike(ctx, bikeID)
		if err != nil {
			return "", fmt.Errorf("could not read the data. %s", err)
		}

		if bike.Make == order.Make && bike.Color == order.Color && bike.Model == order.Model {
			bike.OwnedBy = order.DealerName
			bike.Status = "assigned to a dealer"

			bytes, _ := json.Marshal(bike)

			ctx.GetStub().DelPrivateData(collectionName, orderID)

			err = ctx.GetStub().PutState(bikeID, bytes)

			if err != nil {
				return "", fmt.Errorf("could not add the data %s", err)
			} else {
				return fmt.Sprintf("Deleted order %v and Assigned %v to %v", orderID, bike.BikeId, order.DealerName), nil
			}
		} else {
			return "", fmt.Errorf("order is not matching")
		}
	} else {
		return "", fmt.Errorf("user under following MSPID: %v can't perform this action", clientOrgID)
	}
}

// RegisterBike register bike to the buyer
func (b *BikeContract) RegisterBike(ctx contractapi.TransactionContextInterface, bikeID string, ownerName string, registrationNumber string) (string, error) {
	clientOrgID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("could not get the MSPID %s", err)
	}

	// if clientOrgID == "Org3MSP" {
	// if clientOrgID == "mvd-auto-com" {
	if clientOrgID == "MvdMSP" {
		bike, _ := b.ReadBike(ctx, bikeID)
		bike.Status = fmt.Sprintf("Registered to  %v with plate number %v", ownerName, registrationNumber)
		bike.OwnedBy = ownerName

		bytes, _ := json.Marshal(bike)
		err = ctx.GetStub().PutState(bikeID, bytes)
		if err != nil {
			return "", fmt.Errorf("could not add the updated bike details %s", err)
		} else {
			return fmt.Sprintf("Bike %v successfully registered to %v", bikeID, ownerName), nil
		}

	} else {
		return "", fmt.Errorf("user under following MSPID: %v cannot able to perform this action", clientOrgID)
	}

}