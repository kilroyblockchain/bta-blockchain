#!/bin/bash
RED='\033[0;31m'
BLOD_RED='\033[1;31m'
GREEN='\033[0;32m'
BLOD_GREEN='\033[0;32m'
Color_Off='\033[0m'


#  Check the if the user clone the oracle-connector or not
cd ..
if [ ! -d "oracle-connector" ];
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

#  Check the if the setup or created .env file or not
cd oracle-connector
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

