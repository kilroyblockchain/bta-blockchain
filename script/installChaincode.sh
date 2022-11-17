#!/bin/bash

. utils/envVar.sh

Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

WORK_DIR=/opt/gopath/src/github.com/hyperledger/fabric/peer

export ORDERER0_NAME=orderer0.org.bta.kilroy
export ORDERER0_PORT=7050
export ORDERER_TLS_CA=$WORK_DIR/crypto/ordererOrganizations/orderer.org.bta.kilroy/tls/tlscacerts/tls-localhost-7054.pem

export CLI_NAME=cli.bta.kilroy

installGoDependencies(){
    docker exec $CLI_NAME /bin/sh -c 'cd /opt/gopath/src/github.com/chaincode/; go mod vendor; go env -w GO111MODULE=auto'
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to import go modules"
    successln "---------------------------------------------------------------------------"
    successln "Successfully import go modules"
    successln "---------------------------------------------------------------------------"
}
   
packageChaincode(){
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer lifecycle chaincode package $CHAINCODE_NAME.tar.gz --path github.com/chaincode/${CHAINCODE_NAME} --lang golang --label ${CHAINCODE_NAME}${CHANNEL_NAME}_1
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to package chaincode $CHAINCODE_NAME"
    successln "---------------------------------------------------------------------------"
    successln "Successfully packaged chaincode $CHAINCODE_NAME"
    successln "---------------------------------------------------------------------------"
}

installChaincode(){
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer lifecycle chaincode install $CHAINCODE_NAME.tar.gz

     res=$?
     { set +x; } 2>/dev/null
    verifyResult $res "Failed to install chaincode on peer"
    successln "---------------------------------------------------------------------------"
    successln "Successfully installed chaincode on peer"
    successln "---------------------------------------------------------------------------"
}

checkQueryInstalled(){
    echo "HERE"
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer lifecycle chaincode queryinstalled | tee output.txt
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to check query installed"
    successln "---------------------------------------------------------------------------"
    successln "Successfully checked query installed"
    successln "---------------------------------------------------------------------------"

    cat output.txt
    export PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; p;}' output.txt`
    echo $PACKAGE_ID
    rm output.txt
}

approveChaincode(){

    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer lifecycle chaincode approveformyorg -o $ORDERER0_NAME:$ORDERER0_PORT --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version 1.0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_TLS_CA
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to approve chaincode $CHAINCODE_NAME on channel $CHANNEL_NAME"
    successln "---------------------------------------------------------------------------"
    successln "Successfully approved chaincode $CHAINCODE_NAME on channel $CHANNEL_NAME"
    successln "---------------------------------------------------------------------------"
}

checkCommitReadiness(){
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version 1.0 --sequence 1 --output json
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to check commit of chaincode $CHAINCODE_NAME on channel $CHANNEL_NAME"
    successln "---------------------------------------------------------------------------"
    successln "Successfully checked commit of chaincode $CHAINCODE_NAME on channel $CHANNEL_NAME"
    successln "---------------------------------------------------------------------------"
}

commitChaincode(){
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer lifecycle chaincode commit -o ${ORDERER0_NAME}:$ORDERER0_PORT --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version 1.0 --sequence 1 --tls --cafile $ORDERER_TLS_CA --peerAddresses $PEER_ADMIN_O2_NAME:$PEER_ADMIN_O2_PORT --tlsRootCertFiles $PEER_ADMIN_O2_TLS_ROOTCERT_FILE --peerAddresses $PEER_SH_O3_NAME:$PEER_SH_O3_PORT --tlsRootCertFiles $PEER_SH_O3_TLS_ROOTCERT_FILE --peerAddresses $PEER_MLOPS_O4_NAME:$PEER_MLOPS_O4_PORT --tlsRootCertFiles $PEER_MLOPS_O4_TLS_ROOTCERT_FILE --peerAddresses $PEER_AI_ENGINEER_O5_NAME:$PEER_AI_ENGINEER_O5_PORT --tlsRootCertFiles $PEER_AI_ENGINEER_O5_TLS_ROOTCERT_FILE
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to commit chaincode in channel"
    successln "---------------------------------------------------------------------------"
    successln "Successfully commit chaincode in channel"
    successln "---------------------------------------------------------------------------"
}

commitChaincodeO5AIEngineer(){
    docker exec -e CORE_PEER_ADDRESS=$PEER_NAME:$PEER_PORT -e CORE_PEER_LOCALMSPID=$PEER_MSPID -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/msp $CLI_NAME peer lifecycle chaincode commit -o ${ORDERER0_NAME}:$ORDERER0_PORT --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version 1.0 --sequence 1 --tls --cafile $ORDERER_TLS_CA --peerAddresses $PEER_AI_ENGINEER_O5_NAME:$PEER_AI_ENGINEER_O5_PORT --tlsRootCertFiles $PEER_AI_ENGINEER_O5_TLS_ROOTCERT_FILE
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to commit chaincode in channel"
    successln "---------------------------------------------------------------------------"
    successln "Successfully commit chaincode in channel"
    successln "---------------------------------------------------------------------------"
}

installChaincodeC1Channel(){
    for i in "project" "model-version" "model-experiment" "model-artifact"
    do
        echo "CHAINCODE: $i"
        # ***************O2 ADMIN***************
        export CHAINCODE_NAME=$i
        export CHANNEL_NAME=c1-channel
        export PEER_ADMIN_NAME=peer.o2-admin.bta.kilroy
        export PEER_NAME=peer0.o2-admin.bta.kilroy
        export PEER_PORT=7061
        export PEER_MSPID=PeerO2AdminBtaKilroyMSP
        installGoDependencies
        packageChaincode
        installChaincode
        checkQueryInstalled
        approveChaincode
        checkCommitReadiness

        # ***************O3 STAKE HOLDER***************
        export CHAINCODE_NAME=$i
        export CHANNEL_NAME=c1-channel
        export PEER_ADMIN_NAME=peer.o3-sh.bta.kilroy
        export PEER_NAME=peer0.o3-sh.bta.kilroy
        export PEER_PORT=7071
        export PEER_MSPID=PeerO3ShBtaKilroyMSP
        installChaincode
        checkQueryInstalled
        approveChaincode
        checkCommitReadiness

        # ***************O4 MLOPS ENGINEER***************
        export CHAINCODE_NAME=$i
        export CHANNEL_NAME=c1-channel
        export PEER_ADMIN_NAME=peer.o4-mlops.bta.kilroy
        export PEER_NAME=peer0.o4-mlops.bta.kilroy
        export PEER_PORT=7081
        export PEER_MSPID=PeerO4MLOpsBtaKilroyMSP
        installChaincode
        checkQueryInstalled
        approveChaincode
        checkCommitReadiness


        # ***************O5 AI ENGINEER***************
        export CHAINCODE_NAME=$i
        export CHANNEL_NAME=c1-channel
        export PEER_ADMIN_NAME=peer.o5-ai-engineer.bta.kilroy
        export PEER_NAME=peer0.o5-ai-engineer.bta.kilroy
        export PEER_PORT=7091
        export PEER_MSPID=PeerO5AIEngineerBtaKilroyMSP

        # For commit chaincode need all the organization's tls root cert path
        export PEER_ADMIN_O2_NAME=peer0.o2-admin.bta.kilroy
        export PEER_ADMIN_O2_PORT=7061
        export PEER_ADMIN_O2_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem

        export PEER_SH_O3_NAME=peer0.o3-sh.bta.kilroy
        export PEER_SH_O3_PORT=7071
        export PEER_SH_O3_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem

        export PEER_MLOPS_O4_NAME=peer0.o4-mlops.bta.kilroy
        export PEER_MLOPS_O4_PORT=7081
        export PEER_MLOPS_O4_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem

        export PEER_AI_ENGINEER_O5_NAME=peer0.o5-ai-engineer.bta.kilroy
        export PEER_AI_ENGINEER_O5_PORT=7091
        export PEER_AI_ENGINEER_O5_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem
        installChaincode
        checkQueryInstalled
        approveChaincode
        checkCommitReadiness
        
        commitChaincode
    done
}

installChaincodeO5AIEngineerChannel(){
    for i in "model-version" "model-experiment" "model-artifact"
    do
        echo "CHAINCODE: $i"

        # ***************O5 AI ENGINEER***************
        export CHAINCODE_NAME=$i
        export CHANNEL_NAME=o5-ai-engineer-channel
        export PEER_ADMIN_NAME=peer.o5-ai-engineer.bta.kilroy
        export PEER_NAME=peer0.o5-ai-engineer.bta.kilroy
        export PEER_PORT=7091
        export PEER_MSPID=PeerO5AIEngineerBtaKilroyMSP

        export PEER_AI_ENGINEER_O5_NAME=peer0.o5-ai-engineer.bta.kilroy
        export PEER_AI_ENGINEER_O5_PORT=7091
        export PEER_AI_ENGINEER_O5_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$PEER_ADMIN_NAME/peers/$PEER_NAME/tls/tlscacerts/tls-localhost-7054.pem
        installGoDependencies
        packageChaincode
        installChaincode
        checkQueryInstalled
        approveChaincode
        checkCommitReadiness
        commitChaincodeO5AIEngineer
    done
}

installChaincodeC1Channel
installChaincodeO5AIEngineerChannel