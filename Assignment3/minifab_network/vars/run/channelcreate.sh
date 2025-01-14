#!/bin/bash
# Script to create channel block 0 and then create channel
cp $FABRIC_CFG_PATH/core.yaml /vars/core.yaml
cd /vars
export FABRIC_CFG_PATH=/vars
configtxgen -profile OrgChannel \
  -outputCreateChannelTx autochannel.tx -channelID autochannel

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=192.168.29.146:7004
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/policedepartment.claim.com/peers/peer1.policedepartment.claim.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=policedepartment-claim-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/policedepartment.claim.com/users/Admin@policedepartment.claim.com/msp
export ORDERER_ADDRESS=192.168.29.146:7013
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/claim.com/orderers/orderer2.claim.com/tls/ca.crt
peer channel create -c autochannel -f autochannel.tx -o $ORDERER_ADDRESS \
  --cafile $ORDERER_TLS_CA --tls
