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
cat > .env <<EOF
CONNECTION_FILE_PATH=src/blockchain-files/connection-profile/
ICA_CONTAINER_NAME=ica.o1-super-admin.bta.kilroy
CA_ADMIN_ID=ica-o1-super-admin-bta-kilroy
CA_ADMIN_PWD=Ica-O1-Super-Admin-Bta-Kilroy
CA_MSP_ID=PeerO1SuperAdminBtaKilroyMSP
ORG_NAME=PeerO1SuperAdminBtaKilroy
CERTIFICATE_TYPE=X.509
PEER_NAMES=["peer0.o1-super-admin.bta.kilroy"]
APP_PORT=5004
AUTHORIZATION_TOKEN=aWNhLW8xLXN1cGVyLWFkbWluLWJ0YS1raWxyb3k6SWNhLU8xLVN1cGVyLUFkbWluLUJ0YS1LaWxyb3k=
ADMIN_ID=08db14a1076cd3dd43e99220f53a62635ba0502e3a7d1f89b4e90316ab558330

BTA_BC_CONNECTOR_NAME=bta_bc_connector_o1_super_admin
BTA_BC_CONNECTOR_IMAGE=bta-bc-connector-o1-super-admin
EOF

# Up the docker for o1-super-admin
docker compose up prod

# Goto bta-bc-connector-o2-admin directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o2-admin 
cat > .env <<EOF
CONNECTION_FILE_PATH=src/blockchain-files/connection-profile/
ICA_CONTAINER_NAME=ica.o2-admin.bta.kilroy
CA_ADMIN_ID=ica-o2-admin-bta-kilroy
CA_ADMIN_PWD=Ica-O2-Admin-Bta-Kilroy
CA_MSP_ID=PeerO2AdminBtaKilroyMSP
ORG_NAME=PeerO2AdminBtaKilroy
CERTIFICATE_TYPE=X.509
PEER_NAMES=["peer0.o2-admin.bta.kilroy"]
APP_PORT=5005
AUTHORIZATION_TOKEN=aWNhLW8yLWFkbWluLWJ0YS1raWxyb3k6SWNhLU8yLUFkbWluLUJ0YS1LaWxyb3k=
ADMIN_ID=08db14a1076cd3dd43e99220f53a62635ba0502e3a7d1f89b4e90316ab558330

BTA_BC_CONNECTOR_NAME=bta_bc_connector_o2_admin
BTA_BC_CONNECTOR_IMAGE=bta-bc-connector-o2-admin
EOF

echo "Docker for bta_bc_connector_o2_admin Starting...."
docker compose up prod
echo "Docker for bta_bc_connector_o2_admin started Successfully...."


# Goto bta-bc-connector-o3-sh directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o3-sh
cat > .env <<EOF
CONNECTION_FILE_PATH=src/blockchain-files/connection-profile/
ICA_CONTAINER_NAME=ica.o3-sh.bta.kilroy
CA_ADMIN_ID=ica-o3-sh-bta-kilroy
CA_ADMIN_PWD=Ica-O3-Sh-Bta-Kilroy
CA_MSP_ID=PeerO3ShBtaKilroyMSP
ORG_NAME=PeerO3ShBtaKilroy
CERTIFICATE_TYPE=X.509
PEER_NAMES=["peer0.o3-sh.bta.kilroy"]
APP_PORT=5006
AUTHORIZATION_TOKEN=aWNhLW8zLXNoLWJ0YS1raWxyb3k6SWNhLU8zLVNoLUJ0YS1LaWxyb3k=
ADMIN_ID=08db14a1076cd3dd43e99220f53a62635ba0502e3a7d1f89b4e90316ab558330

BTA_BC_CONNECTOR_NAME=bta_bc_connector_o3_sh
BTA_BC_CONNECTOR_IMAGE=bta-bc-connector-o3-sh
EOF

echo "Docker for bta-bc-connector-o2-admin Starting...."
docker compose up prod
echo "Docker for bta-bc-connector-o2-admin started Successfully...."

# Goto bta-bc-connector-o4-mlops directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o4-mlops
cat > .env <<EOF
CONNECTION_FILE_PATH=src/blockchain-files/connection-profile/
ICA_CONTAINER_NAME=ica.o4-mlops.bta.kilroy
CA_ADMIN_ID=ica-o4-mlops-bta-kilroy
CA_ADMIN_PWD=Ica-O4-MLOps-Bta-Kilroy
CA_MSP_ID=PeerO4MLOpsBtaKilroyMSP
ORG_NAME=PeerO4MLOpsBtaKilroy
CERTIFICATE_TYPE=X.509
PEER_NAMES=["peer0.o4-mlops.bta.kilroy"]
APP_PORT=5007
AUTHORIZATION_TOKEN=aWNhLW80LW1sb3BzLWJ0YS1raWxyb3k6SWNhLU80LU1MT3BzLUJ0YS1LaWxyb3k=
ADMIN_ID=08db14a1076cd3dd43e99220f53a62635ba0502e3a7d1f89b4e90316ab558330

BTA_BC_CONNECTOR_NAME=bta_bc_connector_o4_mlops
BTA_BC_CONNECTOR_IMAGE=bta-bc-connector-o4-mlops
EOF


# Goto bta-bc-connector-o4-mlops directory and create .env file
cd ../$APP_NAME-$BC_CONNECTOR-o5-ai-engineer
cat > .env <<EOF
CONNECTION_FILE_PATH=src/blockchain-files/connection-profile/
ICA_CONTAINER_NAME=ica.o5-ai-engineer.bta.kilroy
CA_ADMIN_ID=ica-o5-ai-engineer-bta-kilroy
CA_ADMIN_PWD=Ica-O5-AI-Engineer-Bta-Kilroy
CA_MSP_ID=PeerO5AIEngineerBtaKilroyMSP
ORG_NAME=PeerO5AIEngineerBtaKilroy
CERTIFICATE_TYPE=X.509
PEER_NAMES=["peer0.o5-ai-engineer.bta.kilroy"]
APP_PORT=5008
AUTHORIZATION_TOKEN=aWNhLW81LWFpLWVuZ2luZWVyLWJ0YS1raWxyb3k6SWNhLU81LUFJLUVuZ2luZWVyLUJ0YS1LaWxyb3k=
ADMIN_ID=08db14a1076cd3dd43e99220f53a62635ba0502e3a7d1f89b4e90316ab558330

BTA_BC_CONNECTOR_NAME=bta_bc_connector_o5_ai_engineer
BTA_BC_CONNECTOR_IMAGE=bta-bc-connector-o5-ai-engineer
EOF


pwd
