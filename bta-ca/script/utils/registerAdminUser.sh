REGISTER_USERNAME=$1
REGISTER_PASSWORD=$2
CA_SERVER_PORT=$3
TLS_ROOT_CERTFILE=$4
REGISTRAR_TLSCA_MSP_DIR=$5
REGISTER_TYPE=$6

ROOT_DIR=$PWD/../
REGISTER_TYPE_RCA="RCA"
REGISTER_TYPE_ICA="ICA"

export FABRIC_CA_CLIENT_HOME=$ROOT_DIR/fabric-ca-client

if [ "$REGISTER_TYPE" == "$REGISTER_TYPE_RCA" ]; then
    $ROOT_DIR/bin/fabric-ca-client register -d --id.name $REGISTER_USERNAME --id.secret $REGISTER_PASSWORD -u https://localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --mspdir $REGISTRAR_TLSCA_MSP_DIR >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Failed to Register RCA Admin '$REGISTER_USERNAME' "
    successln "---------------------------------------------------------------------------"
    successln "Successfully Registered RCA Admin '$REGISTER_USERNAME' "
    successln "---------------------------------------------------------------------------"

    echo "fabric-ca-client register -d --id.name $REGISTER_USERNAME --id.secret $REGISTER_PASSWORD -u https://localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --mspdir $REGISTRAR_TLSCA_MSP_DIR"
elif [ "$REGISTER_TYPE" == "$REGISTER_TYPE_ICA" ]; then
    $ROOT_DIR/bin/fabric-ca-client register -d --id.name $REGISTER_USERNAME --id.secret $REGISTER_PASSWORD -u https://localhost:$CA_SERVER_PORT --id.attrs '"hf.Registrar.Roles=user,admin","hf.Revoker=true","hf.IntermediateCA=true"' --tls.certfiles $TLS_ROOT_CERTFILE --mspdir $REGISTRAR_TLSCA_MSP_DIR >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Failed to Register ICA Admin '$REGISTER_USERNAME' "
    successln "---------------------------------------------------------------------------"
    successln "Successfully Registered ICA Admin '$REGISTER_USERNAME' "
    successln "---------------------------------------------------------------------------"

    echo "fabric-ca-client register -d --id.name $REGISTER_USERNAME --id.secret $REGISTER_PASSWORD -u https://localhost:$CA_SERVER_PORT --id.attrs '"hf.Registrar.Roles=user,admin","hf.Revoker=true","hf.IntermediateCA=true"' --tls.certfiles $TLS_ROOT_CERTFILE --mspdir $REGISTRAR_TLSCA_MSP_DIR"
fi
# TODO: Rename msp key file to key.pem 


