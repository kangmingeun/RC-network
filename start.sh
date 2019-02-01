#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yml down

docker-compose -f docker-compose.yml up -d ca.rgbproject.com orderer.rgbproject.com peer0.org1.rgbproject.com peer0.org2.rgbproject.com couchdb cli

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
# docker exec -it cli bash peer channel create -o orderer.rgbproject.com:7050 -c channelrc -f /etc/hyperledger/configtx/channelrc.tx --tls $CORE_PEER_TSL_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.rgbproject.com/msp" peer0.org1.rgbproject.com peer channel create -o orderer.rgbproject.com:7050 -c channelrc -f /etc/hyperledger/configtx/channel.tx
# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.rgbproject.com/msp" peer0.org1.rgbproject.com peer channel join -b channelrc.block
# Join peer0.org2.example.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.rgbproject.com/msp" peer0.org2.rgbproject.com peer channel fetch 0 channelrc.block -o orderer.rgbproject.com:7050 -c channelrc
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.rgbproject.com/msp" peer0.org2.rgbproject.com peer channel join -b channelrc.block

# docker exec -it cli bash

# peer channel create -o orderer.rgbproject.com:7050 -c channelrc -f ./config/channel.tx --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/rgbproject.com/orderers/orderer.rgbproject.com/msp/tlscacerts/tlsca.rgbproject.com-cert.pem

## peer0.org1
# CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.rgbproject.com/users/Admin@org1.rgbproject.com/msp
# CORE_PEER_ADDRESS=peer0.org1.rgbproject.com:7051
# CORE_PEER_LOCALMSPID="Org1MSP"
# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.rgbproject.com/peers/peer0.org1.rgbproject.com/tls/ca.crt
# peer channel join -b channelrc.block

## peer0.org2
# CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.rgbproject.com/users/Admin@org2.rgbproject.com/msp
# CORE_PEER_ADDRESS=peer0.org2.rgbproject.com:7051
# CORE_PEER_LOCALMSPID="Org2MSP"
# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.rgbproject.com/peers/peer0.org2.rgbproject.com/tls/ca.crt
# peer channel join -b channelrc.block