#!/bin/bash

export BC_CONNECTOR=bc-connector
export APP_NAME=bta

# Check the bta-bc-connector directory is exits or not if not make bta-bc-connector directory
[ -d ../$APP_NAME-$BC_CONNECTOR ] || mkdir ../$APP_NAME-$BC_CONNECTOR

cd ../$APP_NAME-$BC_CONNECTOR


# Check the bc-connector directory is exits or not if exits remove bc-connector directory
if [ -d $BC_CONNECTOR ]; then rm -rf $BC_CONNECTOR; fi


git clone https://bitbucket.org/kilroy/$BC_CONNECTOR.git

cd $BC_CONNECTOR && sudo rm -r .git 

cd ..


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

# # Up the docker for o1-super-admin
# echo "Docker for bta_bc_connector_o1-super-admin Starting...."
# # docker compose up prod
# echo "Docker for bta_bc_connector_o1-super-admin started Successfully...."


# # Goto bta-bc-connector-o2-admin directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o2-admin 

echo "Creating .env file for o2-admin...."
cp -r env-samples/env-o2-admin .env
echo "Created .env file for o2-admin...."


# # Up the docker for o2-admin
# echo "Docker for bta_bc_connector_o2_admin Starting...."
# # docker compose up prod
# echo "Docker for bta_bc_connector_o2_admin started Successfully...."


# # Goto bta-bc-connector-o3-sh directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o3-sh

echo "Creating .env file for o3-sh...."
cp -r env-samples/env-o3-sh .env
echo "Created .env file for o3-sh...."

# # Up the docker for o2-admin
# echo "Docker for bta_bc_connector_o3-sh Starting...."
# # docker compose up prod
# echo "Docker for bta_bc_connector_o3-sh started Successfully...."


# # Goto bta-bc-connector-o4-mlops directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o4-mlops

echo "Creating .env file for o4-mlops...."
cp -r env-samples/env-o4-mlops .env
echo "Created .env file for o3-sh...."

# # Up the docker for o4-mlops
# echo "Docker for bta_bc_connector_o4-mlops Starting...."
# # docker compose up prod
# echo "Docker for bta_bc_connector_o4-mlops started Successfully...."

# # Goto bta-bc-connector-o5-ai-engineer directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o5-ai-engineer

echo "Creating .env file for o5-ai-engineer...."
cp -r env-samples/env-o5-ai-engineer .env
echo "Created .env file for o5-ai-engineer...."

# # Up the docker for o5-ai-engineer
# echo "Docker for bta_bc_connector_o5-ai-engineer Starting...."
# # docker compose up prod
# echo "Docker for bta_bc_connector_o5-ai-engineer started Successfully...."
