#!/bin/bash
BLOD_GREEN='\033[1;32m'
BOLD_YELLOW="\033[1;33m"
Color_Off='\033[0m'

# Export oracle connector repo name
export ORACLE_CONNECTOR_REPO=oracle-connector

# Go to oracle-connector folder
cd ../$ORACLE_CONNECTOR_REPO

# Down The Oracle Connector Docker Container And Remove It's Volumes
echo -e "${GREEN}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BLOD_GREEN}Downing The Oracle Connector Docker Container And Removing It's Volumes${Color_Off}"
docker compose down -v
echo -e "${GREEN}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BLOD_GREEN}Successfully Down The Oracle Connector Docker Conatainer And Removed It's Volumes${Color_Off}"

# Remove The Oracle Connector Docker Images
echo -e "${GREEN}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BLOD_GREEN}Removing Docker Image Of The Oracle Connector${Color_Off}"
docker image rm -f redis:latest obc-connector-dev:1.0.0 
echo -e "${GREEN}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BLOD_GREEN}Successfully Removed Image Of The Oracle Connector${Color_Off}"


echo -e "${BLOD_GREEN}Removing Oracle Connector directory${Color_Off}"
sudo rm -rf ../$ORACLE_CONNECTOR_REPO;
echo -e "${BLOD_GREEN}Successfully Removed Oracle Connector directory${Color_Off}"


echo ""
echo -e "${BOLD_YELLOW}Thank You!!!${Color_Off}"
echo ""
