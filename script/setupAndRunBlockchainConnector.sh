#!/bin/bash

export BC_CONNECTOR=bc-connector
export APP_NAME=bta


# connection profile exports
export CONNECTION_PROFILE_DIR=src/blockchain-files/connection-profile
export SUPER_ADMIN_CONNECTION_PROFILE=connection-profile-peero1superadminbtakilroy.yaml
export ADMIN_CONNECTION_PROFILE=connection-profile-peero2adminbtakilroy.yaml
export STAKEHOLDER_COONECTION_PROFILE=connection-profile-peero3shbtakilroy.yaml
export MLOPS_CONNECTION_PROFILE=connection-profile-peero4mlopsbtakilroy.yaml
export AI_ENGINEER_PROFILE=connection-profile-peero5aiengineerbtakilroy.yaml

 # Getting IP Address For Blockchain Network
export BLOCKCHAIN_NETWORK_IP_ADDRESS=$(ifconfig | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v 127.0.0.1 | head -1 | awk '{ print $2 }')
# echo "The Is address: ${BLOCKCHAIN_NETWORK_IP_ADDRESS}"

# Check bta-bc-connector directory if exits delete else make 
cd ..
if [ -d "$APP_NAME-$BC_CONNECTOR" ]; 
then
    sudo rm -rf $APP_NAME-$BC_CONNECTOR;
fi

mkdir $APP_NAME-$BC_CONNECTOR && cd $APP_NAME-$BC_CONNECTOR
 
# Clone the bc-connector repo from bitbucket
git clone https://bitbucket.org/kilroy/$BC_CONNECTOR.git
cd $BC_CONNECTOR && sudo rm -r .git 
mkdir -p $CONNECTION_PROFILE_DIR

cd ..

# Copy all bc-connector according to users
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o1-super-admim
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o2-admin
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o3-sh
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o4-mlops
cp -r $BC_CONNECTOR $APP_NAME-$BC_CONNECTOR-o5-ai-engineer
sudo rm -r $BC_CONNECTOR


# Goto bta-bc-connector-01-super-admin directory and create .env file
cd $APP_NAME-$BC_CONNECTOR-o1-super-admim 

echo "Creating .env file for o1-super-admin...."
cp -r env-samples/env-o1-super-admin .env
echo "Created .env file for 01-super-admin...."

echo "Setup connection profile for o1-super-admin...."
cp -r connection-profile-samples/sample-$SUPER_ADMIN_CONNECTION_PROFILE  $CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE"
echo "Setup completed connection profile for o1-super-admin...."

# Up the docker for o1-super-admin
# echo "Docker for bta_bc_connector_o1-super-admin Starting...."
# docker compose up prod
# echo "Docker for bta_bc_connector_o1-super-admin started Successfully...."


# Goto bta-bc-connector-o2-admin directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o2-admin 

echo "Creating .env file for o2-admin...."
cp -r env-samples/env-o2-admin .env
echo "Created .env file for o2-admin...."

echo "Setup connection profile for o2-admin...."
cp -r connection-profile-samples/sample-$ADMIN_CONNECTION_PROFILE  $CONNECTION_PROFILE_DIR/$ADMIN_CONNECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE"
echo "Setup completed connection profile for o2-admin...."


# Up the docker for o2-admin
# echo "Docker for bta_bc_connector_o2_admin Starting...."
# docker compose up prod
# echo "Docker for bta_bc_connector_o2_admin started Successfully...."


# Goto bta-bc-connector-o3-sh directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o3-sh

echo "Creating .env file for o3-sh...."
cp -r env-samples/env-o3-sh .env
echo "Created .env file for o3-sh...."

echo "Setup connection profile for o3-sh...."
cp -r connection-profile-samples/sample-$STAKEHOLDER_COONECTION_PROFILE  $CONNECTION_PROFILE_DIR/$STAKEHOLDER_COONECTION_PROFILE

# Set IP Address For Blockchain Network to yaml file
sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE"
echo "Setup completed connection profile for o3-sh...."

# Up the docker for o2-admin
# echo "Docker for bta_bc_connector_o3-sh Starting...."
# docker compose up prod
# echo "Docker for bta_bc_connector_o3-sh started Successfully...."


# Goto bta-bc-connector-o4-mlops directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o4-mlops

echo "Creating .env file for o4-mlops...."
cp -r env-samples/env-o4-mlops .env
echo "Created .env file for o4-mlops...."

echo "Setup connection profile for o4-mlops...."
cp -r connection-profile-samples/sample-$MLOPS_CONNECTION_PROFILE  $CONNECTION_PROFILE_DIR/$MLOPS_CONNECTION_PROFILE
echo "Setup completed connection profile for o4-mlops...."

# Up the docker for o4-mlops
# echo "Docker for bta_bc_connector_o4-mlops Starting...."
# docker compose up prod
# echo "Docker for bta_bc_connector_o4-mlops started Successfully...."

# Goto bta-bc-connector-o5-ai-engineer directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o5-ai-engineer

echo "Creating .env file for o5-ai-engineer...."
cp -r env-samples/env-o5-ai-engineer .env
echo "Created .env file for o5-ai-engineer...."

echo "Setup connection profile for o5-ai-engineer...."
cp -r connection-profile-samples/sample-$AI_ENGINEER_PROFILE  $CONNECTION_PROFILE_DIR/$AI_ENGINEER_PROFILE

# Set IP Address For Blockchain Network to yaml file
sed -i "s/BLOCKCHAIN_NETWORK_IP_ADDRESS/${BLOCKCHAIN_NETWORK_IP_ADDRESS}/g" "$CONNECTION_PROFILE_DIR/$SUPER_ADMIN_CONNECTION_PROFILE"
echo "Setup completed connection profile for o5-ai-engineer...."

# Up the docker for o5-ai-engineer
# echo "Docker for bta_bc_connector_o5-ai-engineer Starting...."
# docker compose up prod
# echo "Docker for bta_bc_connector_o5-ai-engineer started Successfully...."




