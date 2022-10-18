#!/bin/bash
Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

WORK_DIR=/opt/gopath/src/github.com/hyperledger/fabric/peer

export ORDERER0_NAME=orderer0.org.bta.kilroy
export ORDERER0_PORT=7050
export ORDERER_TLS_CA=$WORK_DIR/crypto/ordererOrganizations/orderer.org.bta.kilroy/tls/tlscacerts/tls-localhost-7054.pem

export CLI_NAME=cli.bta.kilroy

createChannel(){
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer channel create -o $ORDERER0_NAME:$ORDERER0_PORT -c $CHANNEL_NAME -f $WORK_DIR/channel-artifacts/$CHANNEL_NAME.tx --tls --cafile $ORDERER_TLS_CA
}


# PEER O1 SUPER ADMIN
# GLOBAL CHANNEL CREATE
export CHANNEL_NAME=global-channel
export PEER_ADMIN_NAME=peer.o1-super-admin.bta.kilroy
export PEER_NAME=peer0.o1-super-admin.bta.kilroy
export PEER_PORT=7051
export PEER_MSPID=PeerO1SuperAdminBtaKilroyMSP
createChannel


# PEER O2 ADMIN
# C1 CHANNEL CREATE
export CHANNEL_NAME=c1-channel
export PEER_ADMIN_NAME=peer.o2-admin.bta.kilroy
export PEER_NAME=peer0.o2-admin.bta.kilroy
export PEER_PORT=7051
export PEER_MSPID=PeerO2AdminBtaKilroyMSP
createChannel


# PEER O5 AI ENGINEER
# C1 CHANNEL CREATE
export CHANNEL_NAME=o5-ai-engineer-channel
export PEER_ADMIN_NAME=peer.o5-ai-engineer.bta.kilroy
export PEER_NAME=peer0.o5-ai-engineer.bta.kilroy
export PEER_PORT=7051
export PEER_MSPID=PeerO5AIEngineerBtaKilroyMSP

createChannel