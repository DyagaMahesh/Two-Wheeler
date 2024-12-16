package chaincode_test

import(
	"encoding/json"
	"fmt"
	"testing"

	"twnauto/contracts"

	"twnauto/test/mocks"


	"github.com/hyperledger/fabric-chaincode-go/pkg/cid"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/stretchr/testify/require"
)

//go:generate counterfeiter -o mocks/transaction.go -fake-name TransactionContext ./bike-contract_test.go transactionContext
type transactionContext interface {
	contractapi.TransactionContextInterface
}

//go:generate counterfeiter -o mocks/chaincodestub.go -fake-name ChaincodeStub ./bike-contract_test.go chaincodeStub
type chaincodeStub interface {
	shim.ChaincodeStubInterface
}

//go:generate counterfeiter -o mocks/clientIdentity.go -fake-name ClientIdentity ./bike-contract_test.go clientIdentity
type clientIdentity interface {
	cid.ClientIdentity
}


const orgMsp string = "manufacturer-auto-com"

func prepMocks(orgMSP string) (*mocks.TransactionContext, *mocks.ChaincodeStub) {
	// create an instance of chaincode stub
	chaincodeStub := &mocks.ChaincodeStub{}

	// create an instance of transaction context
	transactionContext := &mocks.TransactionContext{}

	// Associate chaincode stub with transaction context
	transactionContext.GetStubReturns(chaincodeStub)

	// create an instance of client identity
	clientIdentity := &mocks.ClientIdentity{}

	// Associate chaincode stub with transaction context
	transactionContext.GetClientIdentityReturns(clientIdentity)

	// Equip the client identity with corresponding msp id required
	clientIdentity.GetMSPIDReturns(orgMSP, nil)

	// Return transaction context and chaincode stub
	return transactionContext, chaincodeStub
}

func TestCreateBike(t *testing.T) {
	// Set up mocks
	transactionContext, chaincodeStub := prepMocks(orgMsp)

	// Create BikeContract instance
	bikeAsset := contracts.BikeContract{}

	// Configure mock behavior
	chaincodeStub.GetStateReturns(nil, nil)
	chaincodeStub.PutStateReturns(nil)

	// Call CreateBike with valid input
	result, err := bikeAsset.CreateBike(transactionContext, "bike1", "RoyalEnfield", "hunter350", "Blue", "Factory-01", "2024-01-01")

	// Assert successful creation
	require.NoError(t, err)
	require.Equal(t, "successfully added bike bike1", result)

	// Assert bike already exist
	chaincodeStub.GetStateReturns([]byte{}, nil)
	_, err = bikeAsset.CreateBike(transactionContext, "bike1", "", "", "", "", "")
	require.EqualError(t, err, "the bike, bike1 already exists")

	// Assert reading error
	chaincodeStub.GetStateReturns(nil, fmt.Errorf("some error"))
	_, err = bikeAsset.CreateBike(transactionContext, "bike1", "", "", "", "", "")
	require.EqualError(t, err, "failed to read from world state: some error")
}

func TestReadBike(t *testing.T) {
	// Set up mocks
	transactionContext, chaincodeStub := prepMocks(orgMsp)

	// Create BikeContract instance
	bikeAsset := contracts.BikeContract{}

	// Create pointer to Bike struct
	expectedAsset := &contracts.Bike{BikeId: "bike1"}
	bytes, err := json.Marshal(expectedAsset)
	require.NoError(t, err)


	// Configure mock behavior
	chaincodeStub.GetStateReturns(bytes, nil)

	// Assert successful reading
	bike, err := bikeAsset.ReadBike(transactionContext, "bike1")
	require.NoError(t, err)
	require.Equal(t, expectedAsset, bike)

	// Assert reading error
	chaincodeStub.GetStateReturns(nil, fmt.Errorf("unable to retrieve bike"))
	_, err = bikeAsset.ReadBike(transactionContext, "")
	require.EqualError(t, err, "failed to read from world state: unable to retrieve bike")

	// Assert bike doesn't exist
	chaincodeStub.GetStateReturns(nil, nil)
	bike, err = bikeAsset.ReadBike(transactionContext, "bike1")
	require.EqualError(t, err, "the bike bike1 does not exist")
	require.Nil(t, bike)
}

func TestDeleteBike(t *testing.T) {
	// Set up mocks
	transactionContext, chaincodeStub := prepMocks(orgMsp)

	// Create BikeContract instance
	bikeAsset := contracts.BikeContract{}

	// Create pointer to Bike struct
	bike := &contracts.Bike{BikeId: "bike1"}
	bytes, err := json.Marshal(bike)
	require.NoError(t, err)

	// Configure mock behavior
	chaincodeStub.GetStateReturns(bytes, nil)
	chaincodeStub.DelStateReturns(nil)

	// Assert successful removal of bike
	result, err := bikeAsset.DeleteBike(transactionContext, "bike1")
	require.NoError(t, err)
	require.Equal(t, "bike with id bike1 is deleted from the world state.", result)

	// Assert bike doesn't exist
	chaincodeStub.GetStateReturns(nil, nil)
	_, err = bikeAsset.DeleteBike(transactionContext, "bike1")
	require.EqualError(t, err, "the bike, bike1 does not exist")

	// Assert reading error
	chaincodeStub.GetStateReturns(nil, fmt.Errorf("unable to retrieve bike"))
	_, err = bikeAsset.DeleteBike(transactionContext, "")
	require.EqualError(t, err, "failed to read from world state: unable to retrieve bike")
}