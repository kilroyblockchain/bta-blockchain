

#!/bin/bash

. utils/envVar.sh

Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

WORK_DIR=/opt/gopath/src/github.com/hyperledger/fabric/peer

# export ORDERER0_NAME=orderer0.org.bta.kilroy
# export ORDERER0_PORT=7050
# export ORDERER_TLS_CA=$WORK_DIR/crypto/ordererOrganizations/orderer.org.bta.kilroy/tls/tlscacerts/tls-localhost-7054.pem

export CLI_NAME=cli.bta.kilroy

joinChannel(){
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer channel join -b $CHANNEL_NAME.block
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to join channel ${CHANNEL_NAME}"
}

# PEER O1 SUPER ADMIN
# GLOBAL CHANNEL JOIN
export CHANNEL_NAME=global-channel
export PEER_ADMIN_NAME=peer.o1-super-admin.bta.kilroy
export PEER_NAME=peer0.o1-super-admin.bta.kilroy
export PEER_PORT=7041
export PEER_MSPID=PeerO1SuperAdminBtaKilroyMSP
joinChannel

# PEER O2 ADMIN
# GLOBAL CHANNEL JOIN
export CHANNEL_NAME=global-channel
export PEER_ADMIN_NAME=peer.o2-admin.bta.kilroy
export PEER_NAME=peer0.o2-admin.bta.kilroy
export PEER_PORT=7061
export PEER_MSPID=PeerO2AdminBtaKilroyMSP
joinChannel

# C1 CHANNEL JOIN
export CHANNEL_NAME=c1-channel
joinChannel

# PEER O3 SH
# C1 CHANNEL JOIN
export CHANNEL_NAME=c1-channel
export PEER_ADMIN_NAME=peer.o3-sh.bta.kilroy
export PEER_NAME=peer0.o3-sh.bta.kilroy
export PEER_PORT=7071
export PEER_MSPID=PeerO3ShBtaKilroyMSP
joinChannel

# PEER O4 MLOPS
# C1 CHANNEL JOIN
export CHANNEL_NAME=c1-channel
export PEER_ADMIN_NAME=peer.o4-mlops.bta.kilroy
export PEER_NAME=peer0.o4-mlops.bta.kilroy
export PEER_PORT=7081
export PEER_MSPID=PeerO4MLOpsBtaKilroyMSP
joinChannel

# PEER O5 AI ENGINEER
# C1 CHANNEL JOIN
export CHANNEL_NAME=c1-channel
export PEER_ADMIN_NAME=peer.o5-ai-engineer.bta.kilroy
export PEER_NAME=peer0.o5-ai-engineer.bta.kilroy
export PEER_PORT=7091
export PEER_MSPID=PeerO5AIEngineerBtaKilroyMSP
joinChannel

# PEER O5 AI ENGINEER
# O5 AI ENGINEER CHANNEL JOIN
export CHANNEL_NAME=o5-ai-engineer-channel
export PEER_ADMIN_NAME=peer.o5-ai-engineer.bta.kilroy
export PEER_NAME=peer0.o5-ai-engineer.bta.kilroy
export PEER_PORT=7091
export PEER_MSPID=PeerO5AIEngineerBtaKilroyMSP
joinChannel

successln "----------------------------------------------------------"
successln "----------------------------------------------------------"
successln "Successfully joined channels"
successln "----------------------------------------------------------"
successln "----------------------------------------------------------"