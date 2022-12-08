#!/bin/bash
YELLOW="\033[0;33m"
GREEN='\033[0;32m'
Red='\033[0;31m'
Color_Off='\033[0m'

export BC_CONNECTOR=bc-connector
export APP_NAME=bta

export SUPER_ADMIN_CONNECTOR=o1-super-admin
export ADMIN_CONNECTOR=o2-admin
export STAKEHOLDER_CONNECTOR=o3-sh
export MLOPS_CONNECTOR=o4-mlops
export AI_ENGINEER_CONNETOR=o5-ai-engineer

export BC_CONNECTOR_DIR=../$APP_NAME-$BC_CONNECTOR

if [ ! -d $BC_CONNECTOR_DIR ]
then 
echo -e "${Red}"
echo "----------------------------------------------------------"
echo "There is not setup of blockchain connector."
echo "To setup and run blockchain connector ./setupAndRunBlockchainConnector.sh"
echo "----------------------------------------------------------"
echo -e "${COLOR_OFF}"

exit 0;
fi


cd $BC_CONNECTOR_DIR


removeBcConnector () {
echo -e "${YELLOW}Downing The Super Admin Blockchain Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$SUPER_ADMIN_CONNECTOR/docker-compose.yaml down -v
echo -e "${GREEN}Successfully Down The Super Admin Blockchain Connector Container${Color_Off}"

echo -e "${YELLOW}Removing Docker Image for Super Admin Blockchain Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$SUPER_ADMIN_CONNECTOR-dev:1.0.0 
echo -e "${GREEN}Successfully Removed Image Of The Super Admin Blokchain Connector${Color_Off}"

echo -e "${YELLOW}Downing The Super Admin Blockchain Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$ADMIN_CONNECTOR/docker-compose.yaml down -v
echo -e "${GREEN}Successfully Down The Super Admin Blockchain Connector Container${Color_Off}"

echo -e "${YELLOW}Removing Docker Image for Admin Blockchain Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$ADMIN_CONNECTOR-dev:1.0.0 
echo -e "${GREEN}Successfully Removed Image Of The Admin Blokchain Connector${Color_Off}"

echo -e "${YELLOW}Downing The Stakeholder Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$STAKEHOLDER_CONNECTOR/docker-compose.yaml down -v
echo -e "${GREEN}Successfully Down The Stakeholder Connector Container${Color_Off}"

echo -e "${YELLOW}Removing Docker Image for The Stakeholder Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$STAKEHOLDER_CONNECTOR-dev:1.0.0 
echo -e "${GREEN}Successfully Removed Image Of The Stakeholder Blokchain Connector${Color_Off}"

echo -e "${YELLOW}Downing MLOPS Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$MLOPS_CONNECTOR/docker-compose.yaml down -v
echo -e "${GREEN}Successfully Down MLOPS Connector Container${Color_Off}"

echo -e "${YELLOW}Removing Docker Image for MLOPS Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$MLOPS_CONNECTOR-dev:1.0.0 
echo -e "${GREEN}Successfully Removed Image Of MLOPS Blokchain Connector${Color_Off}"

echo -e "${YELLOW}Downing AI Engineer Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$AI_ENGINEER_CONNETOR/docker-compose.yaml down -v
echo -e "${GREEN}Successfully Down AI Engineer Connector Container${Color_Off}"

echo -e "${YELLOW}Removing Docker Image for AI Engineer Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$AI_ENGINEER_CONNETOR-dev:1.0.0 
echo -e "${GREEN}Successfully Removed Image Of AI Engineer Blokchain Connector${Color_Off}"
}


deleteBcConnectorDirectory () {

# Remove all docker container volumes and images of bc connector
removeBcConnector

echo -e "${YELLOW}Removing BTA Blockchain Connector directory${Color_Off}"
sudo rm -rf ../$APP_NAME-$BC_CONNECTOR;
echo -e "${GREEN}Successfully Removed BTA Blockchain Connector directory${Color_Off}"

}

invalidResponse () {
echo -e "${Red}"
echo "----------------------------------------------------------"
echo "Invalid Response. Please enter the correct value (y/n)."
echo "----------------------------------------------------------"
echo -e "${COLOR_OFF}"
}

while true; do

read -p "Do you also want to remove all the Bc connector data? (y/n) " yn

case $yn in
	[yY] ) deleteBcConnectorDirectory;
		break;;
	[nN] ) removeBcConnector;
		break;;
	* ) invalidResponse;
esac

done

echo -e "${GREEN}"
echo "----------------------------------------------------------"
echo "----------------------------------------------------------"
echo "Successfully stopped and removed Bc connector"
echo "----------------------------------------------------------"
echo "----------------------------------------------------------"
echo -e "${COLOR_OFF}"
