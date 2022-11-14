#!/bin/bash
. utils/envVar.sh

ENROLLMENT_USER=$1
ENROLLMENT_PASSWORD=$2
ENROLLMENT_ORG_NAME=$3

CA_SERVER_PORT=$4
CA_TYPE=$5
TLS_ROOT_CERTFILE=$6
CSR_HOST=$7
ENROLLMENT_TYPE=$8
DOMAIN_NAME=$9

CA_TYPE_TLS="TLS"

ENROLLMENT_TYPE_PEER_ADMIN="PEER_ADMIN"
ENROLLMENT_TYPE_ORDERER_ADMIN="ORDERER_ADMIN"
ENROLLMENT_TYPE_PEER="PEER"
ENROLLMENT_TYPE_ORDERER="ORDERER"

ROOT_DIR=$PWD/../bta-ca

cd $ROOT_DIR/fabric-ca-client
export FABRIC_CA_CLIENT_HOME=$ROOT_DIR/fabric-ca-client

MSP_DIR=""
if [ "$ENROLLMENT_TYPE" = "$ENROLLMENT_TYPE_ORDERER_ADMIN" ]; then
        MSP_DIR=$ROOT_DIR/crypto-config/ordererOrganizations/orderer.$ENROLLMENT_ORG_NAME.$DOMAIN_NAME
elif [ "$ENROLLMENT_TYPE" = "$ENROLLMENT_TYPE_PEER_ADMIN" ]; then
        MSP_DIR=$ROOT_DIR/crypto-config/peerOrganizations/peer.$ENROLLMENT_ORG_NAME.$DOMAIN_NAME
elif [ "$ENROLLMENT_TYPE" = "$ENROLLMENT_TYPE_ORDERER" ]; then
        MSP_DIR=$ROOT_DIR/crypto-config/ordererOrganizations/orderer.$ENROLLMENT_ORG_NAME.$DOMAIN_NAME/orderers/$ENROLLMENT_USER.$ENROLLMENT_ORG_NAME.$DOMAIN_NAME
elif [ "$ENROLLMENT_TYPE" = "$ENROLLMENT_TYPE_PEER" ]; then
        MSP_DIR=$ROOT_DIR/crypto-config/peerOrganizations/peer.$ENROLLMENT_ORG_NAME.$DOMAIN_NAME/peers/$ENROLLMENT_USER.$ENROLLMENT_ORG_NAME.$DOMAIN_NAME
else
    echo "Not found"
fi

addNodeOUPeer(){
{
  printf 'NodeOUs:'
  printf "\n  Enable: true"
  printf "\n  ClientOUIdentifier:"
  printf "\n    Certificate: intermediatecerts/localhost-7056.pem"
  printf "\n    OrganizationalUnitIdentifier: client"
  printf "\n  PeerOUIdentifier:"
  printf "\n    Certificate: intermediatecerts/localhost-7056.pem"
  printf "\n    OrganizationalUnitIdentifier: peer"
  printf "\n  AdminOUIdentifier:"
  printf "\n    Certificate: intermediatecerts/localhost-7056.pem"
  printf "\n    OrganizationalUnitIdentifier: admin"
  printf "\n  OrdererOUIdentifier:"
  printf "\n    Certificate: intermediatecerts/localhost-7056.pem"
  printf "\n    OrganizationalUnitIdentifier: orderer"
} >$ROOT_DIR/config.yaml
cp $ROOT_DIR/config.yaml $MSP_DIR/msp/config.yaml
rm $ROOT_DIR/config.yaml
}

addNodeOUOrderer(){
{
  printf 'NodeOUs:'
  printf "\n  Enable: true"
  printf "\n  ClientOUIdentifier:"
  printf "\n    Certificate: cacerts/localhost-7057.pem"
  printf "\n    OrganizationalUnitIdentifier: client"
  printf "\n  PeerOUIdentifier:"
  printf "\n    Certificate: cacerts/localhost-7057.pem"
  printf "\n    OrganizationalUnitIdentifier: peer"
  printf "\n  AdminOUIdentifier:"
  printf "\n    Certificate: cacerts/localhost-7057.pem"
  printf "\n    OrganizationalUnitIdentifier: admin"
  printf "\n  OrdererOUIdentifier:"
  printf "\n    Certificate: cacerts/localhost-7057.pem"
  printf "\n    OrganizationalUnitIdentifier: orderer"
} >$ROOT_DIR/config.yaml
cp $ROOT_DIR/config.yaml $MSP_DIR/msp/config.yaml
rm $ROOT_DIR/config.yaml
}

if [ "$CA_TYPE" =  "$CA_TYPE_TLS" ]; then
        ENROLLMENT_USER_NAME=$ENROLLMENT_USER-$ENROLLMENT_ORG_NAME-$DOMAIN_NAME
        set -x
        $ROOT_DIR/../bin/fabric-ca-client enroll -d -u https://$ENROLLMENT_USER_NAME:$ENROLLMENT_PASSWORD@localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --enrollment.profile tls --csr.hosts $CSR_HOST --mspdir $MSP_DIR/tls
        res=$?
        { set +x; } 2>/dev/null
        
        verifyResult $res "Failed to Enroll $ENROLLMENT_TYPE '$ENROLLMENT_USER_NAME' for TLS CA"
        successln "---------------------------------------------------------------------------"
        successln "Successfully Enrolled $ENROLLMENT_TYPE '$ENROLLMENT_USER_NAME' for TLS CA"
        successln "---------------------------------------------------------------------------"

        PRIVATE_FILE=$MSP_DIR/tls/keystore
        mv $PRIVATE_FILE/*_sk $PRIVATE_FILE/key.pem
        echo "fabric-ca-client enroll -d -u https://$ENROLLMENT_USER_NAME:$ENROLLMENT_PASSWORD@localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --enrollment.profile tls --csr.hosts $CSR_HOST --mspdir $MSP_DIR/tls"
    else
        ENROLLMENT_USER_NAME=$ENROLLMENT_USER-$ENROLLMENT_ORG_NAME-$DOMAIN_NAME
        set -x
        $ROOT_DIR/../bin/fabric-ca-client enroll -d -u https://$ENROLLMENT_USER_NAME:$ENROLLMENT_PASSWORD@localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --csr.hosts $CSR_HOST --mspdir $MSP_DIR/msp
        res=$?
        { set +x; } 2>/dev/null
        
        verifyResult $res "Failed to Enroll $ENROLLMENT_TYPE '$ENROLLMENT_USER_NAME' for Organization CA"
        successln "---------------------------------------------------------------------------"
        successln "Successfully Enrolled $ENROLLMENT_TYPE '$ENROLLMENT_USER_NAME' for Organization CA"
        successln "---------------------------------------------------------------------------"

        PRIVATE_FILE=$MSP_DIR/msp/keystore
        mv $PRIVATE_FILE/*_sk $PRIVATE_FILE/key.pem

        if [ "$ENROLLMENT_TYPE" = "$ENROLLMENT_TYPE_ORDERER_ADMIN" ] || [ "$ENROLLMENT_TYPE" = "$ENROLLMENT_TYPE_PEER_ADMIN" ]; then
                cp -r $MSP_DIR/tls/tlscacerts $MSP_DIR/msp
        fi

        echo "fabric-ca-client enroll -d -u https://$ENROLLMENT_USER_NAME:$ENROLLMENT_PASSWORD@localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --csr.hosts $CSR_HOST --mspdir $MSP_DIR/msp"

        if [ "$ENROLLMENT_TYPE" = "$ENROLLMENT_TYPE_ORDERER" ] || [ "$ENROLLMENT_TYPE" = "$ENROLLMENT_TYPE_ORDERER_ADMIN" ]; then
                addNodeOUOrderer
        else
                addNodeOUPeer
        fi
        
    fi

# TODO: Rename msp key file to key.pem 


echo $PRIVATE_FILE