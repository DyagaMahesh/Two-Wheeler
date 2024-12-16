#!/bin/bash
cd $FABRIC_CFG_PATH
# cryptogen generate --config crypto-config.yaml --output keyfiles
configtxgen -profile OrdererGenesis -outputBlock genesis.block -channelID systemchannel

configtxgen -printOrg governmentagency-claim-com > JoinRequest_governmentagency-claim-com.json
configtxgen -printOrg insurancecompany-claim-com > JoinRequest_insurancecompany-claim-com.json
configtxgen -printOrg policedepartment-claim-com > JoinRequest_policedepartment-claim-com.json
configtxgen -printOrg vehiclemanufacturer-claim-com > JoinRequest_vehiclemanufacturer-claim-com.json
