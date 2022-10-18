#!/bin/bash
Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

ROOT_DIR=$PWD/../
BTA_NETWORK_DIR=$ROOT_DIR/bta-network

export FABRIC_CFG_PATH=$BTA_NETWORK_DIR/channel-config

$ROOT_DIR/bin/configtxgen -profile OrdererBtaKilroyGenesis -outputBlock $BTA_NETWORK_DIR/channel-artifacts/genesis.block -channelID syschannel

echo -e "${Green}"
echo "-----------------------------------------------------------------------"
echo "-----------------------------------------------------------------------"
echo "Successfully generated genesis block"
echo "-----------------------------------------------------------------------"
echo "-----------------------------------------------------------------------"
echo -e "${Color_Off}"