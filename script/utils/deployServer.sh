. utils/envVar.sh

CA_SERVER_NAME=$1
CA_SERVER_USER=$2
CA_SERVER_PASSWORD=$3
CA_SERVER_TYPE=$4
CA_SERVER_PORT=$5
CA_CLIENT_DIR=$6
OPERATION_LISTEN_ADDRESS=$7
TLSCA_SERVER_DIR=$8
ROOT_CERT_USER=$9
ROOT_CERT_PASSWORD=${10}
ROOT_CERT_PORT=${11}
CA_SERVER_TYPE_TLSCA="TLSCA"
CA_SERVER_TYPE_RCA="RCA"
CA_SERVER_TYPE_ICA="ICA"

ROOT_DIR=$PWD/../bta-ca

mkdir $ROOT_DIR/$CA_SERVER_NAME
cd $ROOT_DIR/$CA_SERVER_NAME

deployCA(){
if [ "$CA_SERVER_TYPE" == "$CA_SERVER_TYPE_TLSCA" ]; then
        echo "TLSCA"
        set -x
        $ROOT_DIR/../bin/fabric-ca-server init -b $CA_SERVER_USER:$CA_SERVER_PASSWORD >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        cat log.txt
        verifyResult $res "Failed to Initilize $CA_SERVER_TYPE '$CA_SERVER_USER' "
        successln "---------------------------------------------------------------------------"
        successln "Successfully Initilized $CA_SERVER_TYPE '$CA_SERVER_USER' "
        successln "---------------------------------------------------------------------------"
        yq -i '(.tls.enabled = true),(.ca.name = "tls-ca")' fabric-ca-server-config.yaml
        yq -i 'del(.signing.profiles.ca)' fabric-ca-server-config.yaml
    elif [ "$CA_SERVER_TYPE" == "$CA_SERVER_TYPE_RCA" ]; then
        echo "RCA"
        mkdir $ROOT_DIR/$CA_SERVER_NAME/tls
        cp $ROOT_DIR/$CA_CLIENT_DIR/tls-ca/$CA_SERVER_USER/msp/signcerts/cert.pem $ROOT_DIR/$CA_SERVER_NAME/tls && cp $ROOT_DIR/$CA_CLIENT_DIR/tls-ca/$CA_SERVER_USER/msp/keystore/key.pem $ROOT_DIR/$CA_SERVER_NAME/tls
        set -x
        $ROOT_DIR/../bin/fabric-ca-server init -b $CA_SERVER_USER:$CA_SERVER_PASSWORD >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        cat log.txt
        verifyResult $res "Failed to Initilize $CA_SERVER_TYPE '$CA_SERVER_USER' "
        successln "---------------------------------------------------------------------------"
        successln "Successfully Initilized $CA_SERVER_TYPE '$CA_SERVER_USER' "
        successln "---------------------------------------------------------------------------"

        yq -i '.port = '$CA_SERVER_PORT' | .tls.certfile = "tls/cert.pem" | .tls.keyfile = "tls/key.pem" | .tls.enabled = true | .ca.name = "'$CA_SERVER_USER'" | .operations.listenAddress = "'$OPERATION_LISTEN_ADDRESS'"' fabric-ca-server-config.yaml
    elif [ "$CA_SERVER_TYPE" == "$CA_SERVER_TYPE_ICA" ]; then
        echo "ICA"
        mkdir $ROOT_DIR/$CA_SERVER_NAME/tls
        cp $ROOT_DIR/$CA_CLIENT_DIR/tls-ca/$CA_SERVER_USER/msp/signcerts/cert.pem $ROOT_DIR/$CA_SERVER_NAME/tls && cp $ROOT_DIR/$CA_CLIENT_DIR/tls-ca/$CA_SERVER_USER/msp/keystore/key.pem $ROOT_DIR/$CA_SERVER_NAME/tls
        cp $ROOT_DIR/$TLSCA_SERVER_DIR/ca-cert.pem $ROOT_DIR/$CA_SERVER_NAME/tls/tls-ca-cert.pem
        set -x
        $ROOT_DIR/../bin/fabric-ca-server init -b $CA_SERVER_USER:$CA_SERVER_PASSWORD >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        cat log.txt
        verifyResult $res "Failed to Initilize $CA_SERVER_TYPE '$CA_SERVER_USER' "
        successln "---------------------------------------------------------------------------"
        successln "Successfully Initilized $CA_SERVER_TYPE '$CA_SERVER_USER' "
        successln "---------------------------------------------------------------------------"

        yq -i '.port = '$CA_SERVER_PORT' | .tls.certfile = "tls/cert.pem" | .tls.keyfile = "tls/key.pem" | .tls.enabled = true | .ca.name = "'$CA_SERVER_USER'" | .csr.cn = "" | .csr.ca.pathlength = 0 | .intermediate.parentserver.url = "https://'$ROOT_CERT_USER':'$ROOT_CERT_PASSWORD'@localhost:'$ROOT_CERT_PORT'" | .intermediate.parentserver.caname = "'$ROOT_CERT_USER'" | .intermediate.enrollment.hosts = "localhost" | .intermediate.enrollment.profile = "ca" | .intermediate.tls.certfiles = "tls/tls-ca-cert.pem" | .operations.listenAddress = "'$OPERATION_LISTEN_ADDRESS'"' fabric-ca-server-config.yaml
    else
        echo "no match for $CA_SERVER_TYPE"
    fi
}

startCA(){
    rm -r $ROOT_DIR/$CA_SERVER_NAME/msp $ROOT_DIR/$CA_SERVER_NAME/ca-cert.pem
    $ROOT_DIR/../bin/fabric-ca-server start
}

deployCA
startCA
