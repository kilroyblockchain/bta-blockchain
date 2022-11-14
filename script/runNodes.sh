#!/bin/bash
Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

ROOT_DIR=$PWD/../
BTA_NETWORK_DIR=$ROOT_DIR/bta-network

#ICA
docker-compose --env-file ../bta-network/ica/.env -f $BTA_NETWORK_DIR/ica/ica-o1-super-admin.yaml -f $BTA_NETWORK_DIR/ica/ica-o2-admin.yaml -f $BTA_NETWORK_DIR/ica/ica-o3-sh.yaml -f $BTA_NETWORK_DIR/ica/ica-o4-mlops.yaml -f $BTA_NETWORK_DIR/ica/ica-o5-ai-engineer.yaml up -d

# PEER
docker-compose --env-file ../bta-network/peers-c1/.env -f $BTA_NETWORK_DIR/peers-c1/peer.o1-super-admin.yaml -f $BTA_NETWORK_DIR/peers-c1/peer.o2-admin.yaml -f $BTA_NETWORK_DIR/peers-c1/peer.o3-sh.yaml -f $BTA_NETWORK_DIR/peers-c1/peer.o4-mlops.yaml -f $BTA_NETWORK_DIR/peers-c1/peer.o5-ai-engineer.yaml up -d
# docker-compose -f $BTA_NETWORK_DIR/peers-c1/peer.o1-super-admin.yaml -f $BTA_NETWORK_DIR/peers-c1/peer.o2-admin.yaml up -d

# ORDERER
docker-compose --env-file ../bta-network/orderer/.env -f $BTA_NETWORK_DIR/orderer/docker-compose.yaml up -d

docker-compose --env-file ../bta-network/cli-c1/.env -f $BTA_NETWORK_DIR/cli-c1/docker-compose.yaml up -d