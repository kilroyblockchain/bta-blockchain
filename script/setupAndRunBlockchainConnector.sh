#!/bin/bash
Magenta='\033[0;35m'
LIGHT_CYAN='\033[0;96m'
GRAY='\033[0;90m'
BOLD_Green='\033[1;32m'
Green='\033[0;32m'
YELLOW="\033[0;33m"
Red='\033[0;31m'
BLUE='\033[0;34m'
Color_Off='\033[0m'

export BC_CONNECTOR=bc-connector
export APP_NAME=bta
export NODE_INFO=node-info

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

# Blockchain node info filenames exports
export SUPER_ADMIN_BC_NODE_INFO_FILE_NAME=PeerO1SuperAdminBtaKilroy.md
export ADMIN_BC_NODE_INFO_FILE_NAME=PeerO2AdminBtaKilroy.md
export STAKEHOLDER_BC_NODE_INFO_FILE_NAME=PeerO3ShBtaKilroy.md
export MLOPS_BC_NODE_INFO_FILE_NAME=PeerO4MLOpsBtaKilroy.md
export AI_ENGINEER_BC_NODE_INFO_FILE_NAME=PeerO5AIEngineerBtaKilroy.md


# Go to one step back
cd ..

# Check bta-bc-connector directory if exits delete
if [ -d "$APP_NAME-$BC_CONNECTOR" ]; 
then
    sudo rm -rf $APP_NAME-$BC_CONNECTOR;  
fi

mkdir $APP_NAME-$BC_CONNECTOR && cd $APP_NAME-$BC_CONNECTOR
mkdir -p  $BC_CONNECTOR-$NODE_INFO
 
# Clone the bc-connector repo from bitbucket
git clone https://bitbucket.org/kilroy/$BC_CONNECTOR.git
cd $BC_CONNECTOR 
git checkout dev

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
mv $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-$AI_ENGINEER


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
}

# Function for setup crypto files for blockchain connector
function setupCryptoFiles() {
echo -e "${Magenta}Setting up crypto files of $1 for blockchain connector....${Color_Off}"
cp -r ../../bta-ca/crypto-config/peerOrganizations/peer.$1.bta.kilroy $PEER_ORGANIZATION_DIR
cp -r ../../bta-ca/fabric-ca-client/org-ca/ica-$1-bta-kilroy $CRYPTO_FILES_DIR
echo -e "${Magenta}Successfully setup crypto files of $1 for blockchain connector....${Color_Off}"
}

# Function for remove docker danling images
removeDanlingImages(){
echo -e "${YELLOW}Starting removing docker danling images${Color_Off}"
REMOVE_DANGLING_IMAGES="docker rmi $(docker images -q -f dangling=true)"
eval $REMOVE_DANGLING_IMAGES
echo -e "${YELLOW}Successfully removed docker danling images${Color_Off}"
}

# Function run bc connector on docker  
function runBcConnectorOnDocker(){
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_$1${Color_Off}"
# docker compose up -d dev
. ./dev-deploy.sh

# Remove development stage image or unused image of the docker
removeDanlingImages

echo -e "${BOLD_Green}Started docker for bta_bc_connector_$1 Successfully${Color_Off}"
}

# Function sample data of the bc node info of the users
function generatBcNodeInfoSampleData(){
echo -e "${BLUE}Generating bc node info sample data of $2${Color_Off}"
source .env
cat << EOF > ../$BC_CONNECTOR-$NODE_INFO/$1
ORG_NAME=$ORG_NAME
BC_CONNECTOR_NODE_URL=http://$BTA_BC_CONNECTOR_NAME:3000
AUTHORIZATION_TOKEN=$AUTHORIZATION_TOKEN
EOF
echo -e "${BLUE}Generated bc node info sample data of $2${Color_Off}"
}

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
# Sample data o1-super-admin on PeerO1SuperAdminBtaKilroy.md file inside the bc-connector-node-info
generatBcNodeInfoSampleData $SUPER_ADMIN_BC_NODE_INFO_FILE_NAME $SUPER_ADMIN
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
# Sample data o1-super-admin on PeerO2AdminBtaKilroy.md file inside the bc-connector-node-info
generatBcNodeInfoSampleData $ADMIN_BC_NODE_INFO_FILE_NAME $ADMIN
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
# Sample data o1-super-admin on PeerO3ShBtaKilroy.md file inside the bc-connector-node-info
generatBcNodeInfoSampleData $STAKEHOLDER_BC_NODE_INFO_FILE_NAME $STAKEHOLDER
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
# Sample data o1-super-admin on PeerO4MLOpsBtaKilroy.md file inside the bc-connector-node-info
generatBcNodeInfoSampleData $MLOPS_BC_NODE_INFO_FILE_NAME $MLOPS
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
# Sample data o1-super-admin on PeerO5AIEngineerBtaKilroy.md file inside the bc-connector-node-info
generatBcNodeInfoSampleData $AI_ENGINEER_BC_NODE_INFO_FILE_NAME $AI_ENGINEER
echo "======================================================================================================================================================================================================>"

echo -e "${Green}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BOLD_Green}Successfully deployed all the blockchain connectors${Color_Off}"
echo -e "${Green}---------------------------------------------------"
echo "---------------------------------------------------"
echo -e "${Color_Off}"
echo -e "${BOLD_Green}Blockchain Connector Node Connections data are saved on the folder:  bta-bc-connector/bc-connector-node-info${Color_Off}"
echo -e ""
