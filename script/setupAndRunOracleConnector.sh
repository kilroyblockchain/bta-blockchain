#!/bin/bash
RED='\033[0;31m'
BLOD_RED='\033[1;31m'
GREEN='\033[0;32m'
BLOD_GREEN='\033[1;32m'
YELLOW="\033[0;33m"
Color_Off='\033[0m'

# Export oracle connector repo name
export ORACLE_CONNECTOR_REPO=oracle-connector


# Function for remove docker danling images
removeDanlingImages(){
echo -e "${YELLOW}Starting removing docker danling images${Color_Off}"
REMOVE_DANGLING_IMAGES="docker rmi $(docker images -q -f dangling=true)"
eval $REMOVE_DANGLING_IMAGES
echo -e "${YELLOW}Successfully removed docker danling images${Color_Off}"
}



#  Check the if the user clone the oracle-connector or not
cd ..
if [ ! -d "$ORACLE_CONNECTOR_REPO" ];
then 
echo -e "${RED}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BLOD_RED}Oracle connector is not cloned yet, Please clone${Color_Off}"
echo -e "${RED}---------------------------------------------------"
echo "---------------------------------------------------"
echo -e "${Color_Off}"
echo -e ""
exit 0 
fi

#  Check the if the setup or created .env file or not or is empty or not
cd $ORACLE_CONNECTOR_REPO
if [[ ! -f ".env" ||  ! -s ".env" ]];
then 
echo -e "${RED}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BLOD_RED}Please set up .env file on the root folder Oracle connector."
echo -e "For sample for .env file you can see the .env-sample file at the root folder of the Oracle connector.${Color_Off}"
echo -e "${RED}---------------------------------------------------"
echo "---------------------------------------------------"
echo -e "${Color_Off}"
echo -e ""
exit 0 
fi

# Run oracle connector docker container
echo -e "${GREEN}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BLOD_GREEN}Oracle connector is docker is starting${Color_Off}"
docker compose up -d dev
echo -e "${GREEN}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BLOD_GREEN}Oracle connector is docker is started successfully${Color_Off}"

# Remove development stage image or unused image of the docker
removeDanlingImages

# After docker container is up the show the success messages
source .env
echo -e "${GREEN}"
echo "---------------------------------------------------"
echo -e "---------------------------------------------------${Color_Off}"
echo -e "${BLOD_GREEN}Oracle connector is up and running on port $PORT${Color_Off}"
echo -e "${GREEN}---------------------------------------------------"
echo "---------------------------------------------------"
echo -e "${Color_Off}"
echo -e ""
