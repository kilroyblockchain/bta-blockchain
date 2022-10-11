. utils/envVar.sh

REGISTER_USERNAME=$1
REGISTER_PASSWORD=$2
CA_SERVER_PORT=$3
TLS_ROOT_CERTFILE=$4
REGISTRAR_TLSCA_MSP_DIR=$5
REGISTER_TYPE=$6
REGISTER_ORG_NAME=$7
DOMAIN_NAME=$8

REGISTER_TYPE_PEER_ADMIN="PEER_ADMIN"
REGISTER_TYPE_ORDERER_ADMIN="ORDERER_ADMIN"

ROOT_DIR=$PWD/../bta-ca

export FABRIC_CA_CLIENT_HOME=$ROOT_DIR/fabric-ca-client

REGISTER_USERNAME=$REGISTER_USERNAME-$REGISTER_ORG_NAME-$DOMAIN_NAME

if [ "$REGISTER_TYPE" == "$REGISTER_TYPE_PEER_ADMIN" ]; then
    set -x
    $ROOT_DIR/../bin/fabric-ca-client register -d --id.name $REGISTER_USERNAME --id.secret $REGISTER_PASSWORD -u https://localhost:$CA_SERVER_PORT --id.type admin --tls.certfiles $TLS_ROOT_CERTFILE --mspdir $REGISTRAR_TLSCA_MSP_DIR
    res=$?
    { set +x; } 2>/dev/null

    verifyResult $res "Failed to Register Peer Admin '$REGISTER_USERNAME' for TLS"
    successln "---------------------------------------------------------------------------"
    successln "Successfully Registered Orderer '$REGISTER_USERNAME' for TLS"
    successln "---------------------------------------------------------------------------"

    echo "fabric-ca-client register -d --id.name $REGISTER_USERNAME --id.secret $REGISTER_PASSWORD -u https://localhost:$CA_SERVER_PORT --id.type admin --tls.certfiles $TLS_ROOT_CERTFILE --mspdir $REGISTRAR_TLSCA_MSP_DIR"
elif [ "$REGISTER_TYPE" == "$REGISTER_TYPE_ORDERER_ADMIN" ]; then
    set -x
    $ROOT_DIR/../bin/fabric-ca-client register -d --id.name $REGISTER_USERNAME --id.secret $REGISTER_PASSWORD -u https://localhost:$CA_SERVER_PORT --id.type admin --tls.certfiles $TLS_ROOT_CERTFILE --mspdir $REGISTRAR_TLSCA_MSP_DIR
    res=$?
    { set +x; } 2>/dev/null

    verifyResult $res "Failed to Register Orderer Admin '$REGISTER_USERNAME' for TLS"
    successln "---------------------------------------------------------------------------"
    successln "Successfully Registered Orderer Admin '$REGISTER_USERNAME' for TLS"
    successln "---------------------------------------------------------------------------"

    echo "fabric-ca-client register -d --id.name $REGISTER_USERNAME --id.secret $REGISTER_PASSWORD -u https://localhost:$CA_SERVER_PORT --id.type admin --tls.certfiles $TLS_ROOT_CERTFILE --mspdir $REGISTRAR_TLSCA_MSP_DIR"
fi
