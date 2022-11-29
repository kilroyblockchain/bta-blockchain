#!/bin/bash
BOLD_Green='\033[1;32m'
BOLD_YELLOW="\033[1;33m"
Color_Off='\033[0m'


export BC_CONNECTOR=bc-connector
export APP_NAME=bta

export SUPER_ADMIN_CONNECTOR=o1-super-admin
export ADMIN_CONNECTOR=o2-admin
export STAKEHOLDER_CONNECTOR=o3-sh
export MLOPS_CONNECTOR=o4-mlops
export AI_ENGINEER_CONNETOR=o5-ai-engineer


cd ../$APP_NAME-$BC_CONNECTOR

echo -e "${BOLD_YELLOW}Downing The Super Admin Blockchain Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$SUPER_ADMIN_CONNECTOR/docker-compose.yaml down -v
echo -e "${BOLD_Green}Successfully Down The Super Admin Blockchain Connector Container${Color_Off}"

echo -e "${BOLD_YELLOW}Removing Docker Image for Super Admin Blockchain Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$SUPER_ADMIN_CONNECTOR-dev:1.0.0 
echo -e "${BOLD_Green}Successfully Removed Image Of The Super Admin Blokchain Connector${Color_Off}"

echo -e "${BOLD_YELLOW}Downing The Super Admin Blockchain Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$ADMIN_CONNECTOR/docker-compose.yaml down -v
echo -e "${BOLD_Green}Successfully Down The Super Admin Blockchain Connector Container${Color_Off}"

echo -e "${BOLD_YELLOW}Removing Docker Image for Admin Blockchain Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$ADMIN_CONNECTOR-dev:1.0.0 
echo -e "${BOLD_Green}Successfully Removed Image Of The Admin Blokchain Connector${Color_Off}"

echo -e "${BOLD_YELLOW}Downing The Stakeholder Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$STAKEHOLDER_CONNECTOR/docker-compose.yaml down -v
echo -e "${BOLD_Green}Successfully Down The Stakeholder Connector Container${Color_Off}"

echo -e "${BOLD_YELLOW}Removing Docker Image for The Stakeholder Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$STAKEHOLDER_CONNECTOR-dev:1.0.0 
echo -e "${BOLD_Green}Successfully Removed Image Of The Stakeholder Blokchain Connector${Color_Off}"

echo -e "${BOLD_YELLOW}Downing MLOPS Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$MLOPS_CONNECTOR/docker-compose.yaml down -v
echo -e "${BOLD_Green}Successfully Down MLOPS Connector Container${Color_Off}"

echo -e "${BOLD_YELLOW}Removing Docker Image for MLOPS Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$MLOPS_CONNECTOR-dev:1.0.0 
echo -e "${BOLD_Green}Successfully Removed Image Of MLOPS Blokchain Connector${Color_Off}"

echo -e "${BOLD_YELLOW}Downing AI Engineer Connector Container${Color_Off}"
docker compose -f $APP_NAME-$BC_CONNECTOR-$AI_ENGINEER_CONNETOR/docker-compose.yaml down -v
echo -e "${BOLD_Green}Successfully Down AI Engineer Connector Container${Color_Off}"

echo -e "${BOLD_YELLOW}Removing Docker Image for AI Engineer Connector${Color_Off}"
docker image rm -f $APP_NAME-$BC_CONNECTOR-$AI_ENGINEER_CONNETOR-dev:1.0.0 
echo -e "${BOLD_Green}Successfully Removed Image Of AI Engineer Blokchain Connector${Color_Off}"

echo -e "${BOLD_YELLOW}Removing BTA Blockchain Connector directory${Color_Off}"
sudo rm -rf ../$APP_NAME-$BC_CONNECTOR;
echo -e "${BOLD_Green}Successfully Removed BTA Blockchain Connector directory${Color_Off}"

echo ""
echo -e "${BOLD_YELLOW}Thank You!!!${Color_Off}"
echo ""
