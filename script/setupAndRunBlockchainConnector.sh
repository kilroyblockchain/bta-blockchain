#!/bin/bash
Magenta='\033[0;35m'
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


# Function for setup crypto files for blockchain connector
function setupCryptoFiles() {
echo -e "${Magenta}Setting up crypto files of $1 for blockchain connector${Color_Off}"
cp -r ../../bta-ca/crypto-config/peerOrganizations/peer.$1.bta.kilroy $PEER_ORGANIZATION_DIR
cp -r ../../bta-ca/fabric-ca-client/org-ca/ica-$1-bta-kilroy $CRYPTO_FILES_DIR
echo -e "${Magenta}Successfully setup crypto files of $1 for blockchain connector${Color_Off}"
}

# Function for set up connection profile
# Function for set for blockchain network ip
# Remove non-named image

# Goto bta-bc-connector-o1-super-admin directory and setup .env file and setup connection profile
echo "======================================================================================================================================================================================================>"
cd $APP_NAME-$BC_CONNECTOR-$SUPER_ADMIN 

echo "Creating .env file for $SUPER_ADMIN...."
cp -r env-samples/env-$SUPER_ADMIN .env
echo "Created .env file for $SUPER_ADMIN...."

echo "Setup connection profile for $SUPER_ADMIN...."
cp -r connection-profile-samples/sample-$SUPER_ADMIN_CONNECTION_PROFILE  $CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE"
fi
echo "Setup completed connection profile for $SUPER_ADMIN...."

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $SUPER_ADMIN

# Up the docker for o1-super-admin
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_$SUPER_ADMIN${Color_Off}"
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_$SUPER_ADMIN Successfully${Color_Off}"
echo "======================================================================================================================================================================================================>"

# # Goto bta-bc-connector-o2-admin directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-$ADMIN 

echo "Creating .env file for $ADMIN...."
cp -r env-samples/env-$ADMIN .env
echo "Created .env file for $ADMIN...."

echo "Setup connection profile for $ADMIN...."
cp -r connection-profile-samples/sample-$ADMIN_CONNECTION_PROFILE  $CONNECTION_PROFILE_DIR/$ADMIN_CONNECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$ADMIN_CONNECTION_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$ADMIN_CONNECTION_PROFILE"
fi
echo "Setup completed connection profile for $ADMIN...."

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $ADMIN

# Up the docker for o2-admin
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_$ADMIN${Color_Off}" 
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_$ADMIN Successfully${Color_Off}"
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o3-sh directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-$STAKEHOLDER

echo "Creating .env file for $STAKEHOLDER...."
cp -r env-samples/env-$STAKEHOLDER .env
echo "Created .env file for $STAKEHOLDER...."

echo "Setup connection profile for $STAKEHOLDER...."
cp -r connection-profile-samples/sample-$STAKEHOLDER_COONECTION_PROFILE  $CONNECTION_PROFILE_DIR/$STAKEHOLDER_COONECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$STAKEHOLDER_COONECTION_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$STAKEHOLDER_COONECTION_PROFILE"
fi
echo "Setup completed connection profile for $STAKEHOLDER...."

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $STAKEHOLDER

Up the docker for o3-sh
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_$STAKEHOLDER${Color_Off}"
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_$STAKEHOLDER Successfully${Color_Off}"
echo "======================================================================================================================================================================================================>"

# # Goto bta-bc-connector-o4-mlops directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-$MLOPS

echo "Creating .env file for $MLOPS...."
cp -r env-samples/env-$MLOPS .env
echo "Created .env file for $MLOPS...."

echo "Setup connection profile for $MLOPS...."
cp -r connection-profile-samples/sample-$MLOPS_CONNECTION_PROFILE  $CONNECTION_PROFILE_DIR/$MLOPS_CONNECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$MLOPS_CONNECTION_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$MLOPS_CONNECTION_PROFILE"
fi
echo "Setup completed connection profile for $MLOPS...."

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $MLOPS

# Up the docker for o4-mlops
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_$MLOPS${Color_Off}"
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_$MLOPS Successfully${Color_Off}"
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o5-ai-engineer directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-$AI_ENGINEER

echo "Creating .env file for $AI_ENGINEER...."
cp -r env-samples/env-$AI_ENGINEER .env
echo "Created .env file for $AI_ENGINEER...."

echo "Setup connection profile for $AI_ENGINEER...."
cp -r connection-profile-samples/sample-$AI_ENGINEER_PROFILE  $CONNECTION_PROFILE_DIR/$AI_ENGINEER_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$AI_ENGINEER_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$AI_ENGINEER_PROFILE"
fi
echo "Setup completed connection profile for $AI_ENGINEER...."

# Copy the crypto-config from bta-ca and paste on the blockchain connector at src/blockchain-files/crypto-files.
setupCryptoFiles $AI_ENGINEER


# Up the docker for o5-ai-engineer
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_$AI_ENGINEER${Color_Off}"
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_$AI_ENGINEER Successfully${Color_Off}"
echo "======================================================================================================================================================================================================>"

echo ""
echo -e "${BOLD_YELLOW}Thank You!!!${Color_Off}"
echo ""
