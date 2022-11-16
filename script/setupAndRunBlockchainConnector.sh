#!/bin/bash
Magenta='\033[0;35m'
LIGHT_CYAN='\033[0;96m'
GRAY='\033[0;90m'
BOLD_Green='\033[1;32m'
BOLD_YELLOW="\033[1;33m"
Color_Off='\033[0m'

export BC_CONNECTOR=bc-connector
export APP_NAME=bta

# Blockchain connector directories exports
export CONNECTION_PROFILE_DIR=src/blockchain-files/connection-profile
export CRYPTO_FILES_DIR=src/blockchain-files/crypto-files
export ORDERER_ORGANIZATION_DIR=$CRYPTO_FILES_DIR/ordererOrganizations
export PEER_ORGANIZATION_DIR=$CRYPTO_FILES_DIR/peerOrganizations

# connection profile exports
export SUPER_ADMIN_CONNECTION_PROFILE=connection-profile-peero1superadminbtakilroy.yaml
export ADMIN_CONNECTION_PROFILE=connection-profile-peero2adminbtakilroy.yaml
export STAKEHOLDER_COONECTION_PROFILE=connection-profile-peero3shbtakilroy.yaml
export MLOPS_CONNECTION_PROFILE=connection-profile-peero4mlopsbtakilroy.yaml
export AI_ENGINEER_PROFILE=connection-profile-peero5aiengineerbtakilroy.yaml

# Blockchain users exports
export SUPER_ADMIN=o1-super-admin
export ADMIN=o2-admin
export STAKEHOLDER=o3-sh
export MLOPS=o4-mlops
export AI_ENGINEER=o5-ai-engineer

MAC_OS="darwin-amd64"
LINUX_OS="linux-amd64"
ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m |sed 's/x86_64/amd64/g')" |sed 's/darwin-arm64/darwin-amd64/g')

# Getting IP Address For Blockchain Network
export BLOCKCHAIN_NETWORK_IP_ADDRESS=$(ifconfig | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v 127.0.0.1 | head -1 | awk '{ print $2 }')

# Go to one step back
cd ..

# Check bta-bc-connector directory if exits delete
if [ -d "$APP_NAME-$BC_CONNECTOR" ]; 
then
    sudo rm -rf $APP_NAME-$BC_CONNECTOR;
fi

mkdir $APP_NAME-$BC_CONNECTOR && cd $APP_NAME-$BC_CONNECTOR
 
# Clone the bc-connector repo from bitbucket
git clone https://bitbucket.org/kilroy/$BC_CONNECTOR.git
cd $BC_CONNECTOR && sudo rm -r .git 

# Make essential directories for blockchain connector 
mkdir -p $CONNECTION_PROFILE_DIR
mkdir -p $ORDERER_ORGANIZATION_DIR
mkdir -p $PEER_ORGANIZATION_DIR

# Copy orderer organization to blockchain connector
cp -r ../../bta-ca/crypto-config/ordererOrganizations $ORDERER_ORGANIZATION_DIR

# Go to one step back
cd ..

# Copy all bc-connector according to users
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-$SUPER_ADMIN
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-$ADMIN
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-$STAKEHOLDER
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-$MLOPS
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-$AI_ENGINEER
sudo rm -r $BC_CONNECTOR


# Function for setup the .env file for each bc connector
function setupDotEnv(){
echo -e "${GRAY}Creating .env file for $1....${Color_Off}"
cp -r env-samples/env-$1 .env
echo -e "${GRAY}Created .env file for $1....${Color_Off}"
}

# Function for setup connection profile for each bc connector
function setupConnectionProfile(){
echo -e "${LIGHT_CYAN}Setup connection profile for $1....${Color_Off}"
cp -r connection-profile-samples/sample-$2  $CONNECTION_PROFILE_DIR/$2

# Set IP Address For Blockchain Network to yaml file on connection profile
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$2"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$2"
fi
echo -e "${LIGHT_CYAN}Setup completed connection profile for $1....${Color_Off}"

}

# Function for setup crypto files for blockchain connector
function setupCryptoFiles() {
echo -e "${Magenta}Setting up crypto files of $1 for blockchain connector....${Color_Off}"
cp -r ../../bta-ca/crypto-config/peerOrganizations/peer.$1.bta.kilroy $PEER_ORGANIZATION_DIR
cp -r ../../bta-ca/fabric-ca-client/org-ca/ica-$1-bta-kilroy $CRYPTO_FILES_DIR
echo -e "${Magenta}Successfully setup crypto files of $1 for blockchain connector....${Color_Off}"
}


# Function run bc connector on docker  
function runBcConnectorOnDocker(){
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_$1${Color_Off}"
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_$1 Successfully${Color_Off}"
}

# Remove non-named image

echo "======================================================================================================================================================================================================>"
# Goto bta-bc-connector-o1-super-admin directory and setup .env file and setup connection profile
cd $APP_NAME-$BC_CONNECTOR-$SUPER_ADMIN 

# Set .env file for o1-super-admin
setupDotEnv $SUPER_ADMIN

# Setup connection profile for o1-super-admin
setupConnectionProfile $SUPER_ADMIN $SUPER_ADMIN_CONNECTION_PROFILE

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $SUPER_ADMIN

# Up the docker for o1-super-admin
runBcConnectorOnDocker $SUPER_ADMIN
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o2-admin directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-$ADMIN 

# Set .env file for o2-admin
setupDotEnv $ADMIN

# Setup connection profile for o2-admin
setupConnectionProfile $ADMIN $ADMIN_CONNECTION_PROFILE

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $ADMIN

# Up the docker for o2-admin
runBcConnectorOnDocker $ADMIN
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o3-sh directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-$STAKEHOLDER

# Set .env file for o3-sh
setupDotEnv $STAKEHOLDER

# Setup connection profile for o3-sh
setupConnectionProfile $STAKEHOLDER $STAKEHOLDER_COONECTION_PROFILE

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $STAKEHOLDER

# Up the docker for o3-sh
runBcConnectorOnDocker $STAKEHOLDER
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o4-mlops directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-$MLOPS

# Set .env file for o4-mlops
setupDotEnv $MLOPS

# Setup connection profile for o4-mlops
setupConnectionProfile $MLOPS $MLOPS_CONNECTION_PROFILE

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $MLOPS

# Up the docker for o4-mlops
runBcConnectorOnDocker $MLOPS
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o5-ai-engineer directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-$AI_ENGINEER

# Set .env file for o5-ai-engineer
setupDotEnv $AI_ENGINEER

# Setup connection profile for o5-ai-engineer
setupConnectionProfile $AI_ENGINEER $AI_ENGINEER_PROFILE

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $AI_ENGINEER

# Up the docker for o5-ai-engineer
runBcConnectorOnDocker $AI_ENGINEER
echo "======================================================================================================================================================================================================>"

echo ""
echo -e "${BOLD_YELLOW}Thank You!!!${Color_Off}"
echo ""
