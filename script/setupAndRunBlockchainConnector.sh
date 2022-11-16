#!/bin/bash
BOLD_Green='\033[1;32m'
BOLD_YELLOW="\033[1;33m"
Color_Off='\033[0m'

export BC_CONNECTOR=bc-connector
export APP_NAME=bta

# connection profile exports
export CONNECTION_PROFILE_DIR=src/blockchain-files/connection-profile
export SUPER_ADMIN_CONNECTION_PROFILE=connection-profile-peero1superadminbtakilroy.yaml
export ADMIN_CONNECTION_PROFILE=connection-profile-peero2adminbtakilroy.yaml
export STAKEHOLDER_COONECTION_PROFILE=connection-profile-peero3shbtakilroy.yaml
export MLOPS_CONNECTION_PROFILE=connection-profile-peero4mlopsbtakilroy.yaml
export AI_ENGINEER_PROFILE=connection-profile-peero5aiengineerbtakilroy.yaml


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
mkdir -p $CONNECTION_PROFILE_DIR

# Go to one step back
cd ..

# Copy all bc-connector according to users
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o1-super-admim
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o2-admin
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o3-sh
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o4-mlops
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o5-ai-engineer
sudo rm -r $BC_CONNECTOR


# Goto bta-bc-connector-01-super-admin directory and setup .env file and setup connection profile
echo "======================================================================================================================================================================================================>"
cd $APP_NAME-$BC_CONNECTOR-o1-super-admim 

echo "Creating .env file for o1-super-admin...."
cp -r env-samples/env-o1-super-admin .env
echo "Created .env file for 01-super-admin...."

echo "Setup connection profile for o1-super-admin...."
cp -r connection-profile-samples/sample-$SUPER_ADMIN_CONNECTION_PROFILE  $CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE"
fi
echo "Setup completed connection profile for o1-super-admin...."

# Up the docker for o1-super-admin
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_o1-super-admin${Color_Off}"
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_o1-super-admin Successfully.........${Color_Off}"
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o2-admin directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-o2-admin 

echo "Creating .env file for o2-admin...."
cp -r env-samples/env-o2-admin .env
echo "Created .env file for o2-admin...."

echo "Setup connection profile for o2-admin...."
cp -r connection-profile-samples/sample-$ADMIN_CONNECTION_PROFILE  $CONNECTION_PROFILE_DIR/$ADMIN_CONNECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$ADMIN_CONNECTION_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$ADMIN_CONNECTION_PROFILE"
fi
echo "Setup completed connection profile for o2-admin...."

# Up the docker for o2-admin
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_o2_admin" 
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_o2_admin Successfully${Color_Off}"
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o3-sh directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-o3-sh

echo "Creating .env file for o3-sh...."
cp -r env-samples/env-o3-sh .env
echo "Created .env file for o3-sh...."

echo "Setup connection profile for o3-sh...."
cp -r connection-profile-samples/sample-$STAKEHOLDER_COONECTION_PROFILE  $CONNECTION_PROFILE_DIR/$STAKEHOLDER_COONECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$STAKEHOLDER_COONECTION_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$STAKEHOLDER_COONECTION_PROFILE"
fi
echo "Setup completed connection profile for o3-sh...."

# Up the docker for o2-admin
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_o3-sh ${Color_Off}"
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_o3-sh Successfully${Color_Off}"
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o4-mlops directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-o4-mlops

echo "Creating .env file for o4-mlops...."
cp -r env-samples/env-o4-mlops .env
echo "Created .env file for o4-mlops...."

echo "Setup connection profile for o4-mlops...."
cp -r connection-profile-samples/sample-$MLOPS_CONNECTION_PROFILE  $CONNECTION_PROFILE_DIR/$MLOPS_CONNECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$MLOPS_CONNECTION_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$MLOPS_CONNECTION_PROFILE"
fi
echo "Setup completed connection profile for o4-mlops...."

# Up the docker for o4-mlops
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_o4-mlops${Color_Off}"
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_o4-mlops Successfully${Color_Off}"
echo "======================================================================================================================================================================================================>"

# Goto bta-bc-connector-o5-ai-engineer directory and setup .env file and setup connection profile
cd ../$APP_NAME-$BC_CONNECTOR-o5-ai-engineer

echo "Creating .env file for o5-ai-engineer...."
cp -r env-samples/env-o5-ai-engineer .env
echo "Created .env file for o5-ai-engineer...."

echo "Setup connection profile for o5-ai-engineer...."
cp -r connection-profile-samples/sample-$AI_ENGINEER_PROFILE  $CONNECTION_PROFILE_DIR/$AI_ENGINEER_PROFILE

# Set IP Address For Blockchain Network to yaml file
if [ "$ARCH" = "$MAC_OS" ]; 
then
    sed -i "" "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$AI_ENGINEER_PROFILE"
else 
    sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$AI_ENGINEER_PROFILE"
fi
echo "Setup completed connection profile for o5-ai-engineer...."

# Up the docker for o5-ai-engineer
echo "======================================================================================================================================================================================================>"
echo -e "${BOLD_Green}Starting docker for bta_bc_connector_o5-ai-engineer${Color_Off}"
docker compose up -d prod
echo -e "${BOLD_Green}Started docker for bta_bc_connector_o5-ai-engineer Successfully${Color_Off}"
echo "======================================================================================================================================================================================================>"

echo ""
echo -e "${BOLD_YELLOW}Thank You!!!${Color_Off}"
echo ""
