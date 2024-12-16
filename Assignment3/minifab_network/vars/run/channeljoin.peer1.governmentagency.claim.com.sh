#!/bin/bash
# Script to join a peer to a channel
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=192.168.29.146:7005
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/governmentagency.claim.com/peers/peer1.governmentagency.claim.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=governmentagency-claim-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/governmentagency.claim.com/users/Admin@governmentagency.claim.com/msp
export ORDERER_ADDRESS=192.168.29.146:7012
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/claim.com/orderers/orderer1.claim.com/tls/ca.crt
if [ ! -f "autochannel.genesis.block" ]; then
  peer channel fetch oldest -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA \
  --tls -c autochannel /vars/autochannel.genesis.block
fi

peer channel join -b /vars/autochannel.genesis.block \
  -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA --tls
