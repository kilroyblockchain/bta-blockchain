#!/bin/bash
Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

ROOT_DIR=$PWD/../
BTA_NETWORK_DIR=$ROOT_DIR/bta-network
CONFIGTXGEN=$ROOT_DIR/bin/configtxgen

export FABRIC_CFG_PATH=$BTA_NETWORK_DIR/channel-config

export CHANNEL_NAME=global-channel && $CONFIGTXGEN -profile GlobalChannel -outputCreateChannelTx $BTA_NETWORK_DIR/channel-artifacts/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME

export CHANNEL_NAME=c1-channel && $CONFIGTXGEN -profile C1Channel -outputCreateChannelTx $BTA_NETWORK_DIR/channel-artifacts/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME

export CHANNEL_NAME=o5-ai-engineer-channel && $CONFIGTXGEN -profile O5AIEngineerChannel -outputCreateChannelTx $BTA_NETWORK_DIR/channel-artifacts/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME

echo -e "${Green}"
echo "-----------------------------------------------------------------------"
echo "-----------------------------------------------------------------------"
echo "Successfully generated channel configuration files"
echo "-----------------------------------------------------------------------"
echo "-----------------------------------------------------------------------"
echo -e "${Color_Off}"
