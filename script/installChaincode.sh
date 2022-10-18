Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

WORK_DIR=/opt/gopath/src/github.com/hyperledger/fabric/peer

export ORDERER0_NAME=orderer0.org.bta.kilroy
export ORDERER0_PORT=7050
export ORDERER_TLS_CA=$WORK_DIR/crypto/ordererOrganizations/orderer.org.bta.kilroy/tls/tlscacerts/tls-localhost-7054.pem

export CLI_NAME=cli.bta.kilroy

installChaincode(){
    docker exec $CLI_NAME /bin/sh -c 'cd /opt/gopath/src/github.com/chaincode/; go mod vendor; go env -w GO111MODULE=auto'
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer lifecycle chaincode package $CHAINCODE_NAME.tar.gz --path github.com/chaincode/${CHAINCODE_NAME} --lang golang --label ${CHAINCODE_NAME}${CHANNEL_NAME}_1
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer lifecycle chaincode install $CHAINCODE_NAME.tar.gz
}

export CHAINCODE_NAME=project
export CHANNEL_NAME=c1-channel
export PEER_ADMIN_NAME=peer.o2-admin.bta.kilroy
export PEER_NAME=peer0.o2-admin.bta.kilroy
export PEER_PORT=7061
export PEER_MSPID=PeerO2AdminBtaKilroyMSP
installChaincode