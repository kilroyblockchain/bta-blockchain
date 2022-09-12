. utils/envVar.sh

CA_SERVER_USER=$1
CA_SERVER_PASSWORD=$2
CA_SERVER_TYPE=$3
CA_SERVER_PORT=$4
ENROLLMENT_TYPE=$5
TLS_ROOT_CERTFILE=$6
CSR_HOST=$7

CA_SERVER_TYPE_TLSCA="TLSCA"
#CA_SERVER_TYPE_RCA="RCA"
ENROLLMENT_TYPE_TLS="TLS"
ROOT_DIR=$PWD/../


if [ "$CA_SERVER_TYPE" == "$CA_SERVER_TYPE_TLSCA" ]; then
    mkdir $ROOT_DIR/fabric-ca-client
    mkdir $ROOT_DIR/fabric-ca-client/tls-root-cert
    cp -r $ROOT_DIR/fabric-ca-server-tls/ca-cert.pem $ROOT_DIR/fabric-ca-client/tls-root-cert/tls-ca-cert.pem
else
    echo "no match"
fi


cd $ROOT_DIR/fabric-ca-client
export FABRIC_CA_CLIENT_HOME=$ROOT_DIR/fabric-ca-client

    if [ "$ENROLLMENT_TYPE" ==  "$ENROLLMENT_TYPE_TLS" ]; then
    echo "INSIDE ***************";
        set -x
        $ROOT_DIR/bin/fabric-ca-client enroll -d -u https://$CA_SERVER_USER:$CA_SERVER_PASSWORD@localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --enrollment.profile tls --csr.hosts $CSR_HOST --mspdir tls-ca/$CA_SERVER_USER/msp >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        cat log.txt
        verifyResult $res "Failed to Enroll Admin User '$CA_SERVER_USER' for TLS"
        successln "---------------------------------------------------------------------------"
        successln "Successfully Enrolled Admin User '$CA_SERVER_USER' for TLS"
        successln "---------------------------------------------------------------------------"
        PRIVATE_FILE=$ROOT_DIR/fabric-ca-client/tls-ca/$CA_SERVER_USER/msp/keystsore
        
        mv $PRIVATE_FILE/*_sk $PRIVATE_FILE/key.pem
        echo "fabric-ca-client enroll -d -u https://$CA_SERVER_USER:$CA_SERVER_PASSWORD@localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --enrollment.profile tls --csr.hosts $CSR_HOST --mspdir tls-ca/$CA_SERVER_USER/msp"
    else
        $ROOT_DIR/bin/fabric-ca-client enroll -d -u https://$CA_SERVER_USER:$CA_SERVER_PASSWORD@localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --csr.hosts $CSR_HOST --mspdir org-ca/$CA_SERVER_USER/msp >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        cat log.txt
        verifyResult $res "Failed to Enroll Admin User '$CA_SERVER_USER' for Organization CA"
        successln "---------------------------------------------------------------------------"
        successln "Successfully Enrolled Admin User '$CA_SERVER_USER' for Organization CA"
        successln "---------------------------------------------------------------------------"

        PRIVATE_FILE=$ROOT_DIR/fabric-ca-client/org-ca/$CA_SERVER_USER/msp/keystore
        mv $PRIVATE_FILE/*_sk $PRIVATE_FILE/key.pem
        echo "fabric-ca-client enroll -d -u https://$CA_SERVER_USER:$CA_SERVER_PASSWORD@localhost:$CA_SERVER_PORT --tls.certfiles $TLS_ROOT_CERTFILE --csr.hosts $CSR_HOST --mspdir org-ca/$CA_SERVER_USER/msp"
    fi

# TODO: Rename msp key file to key.pem 


echo $PRIVATE_FILE
