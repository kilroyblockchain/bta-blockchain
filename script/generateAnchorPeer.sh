Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

ROOT_DIR=$PWD/../
BTA_NETWORK_DIR=$ROOT_DIR/bta-network

export FABRIC_CFG_PATH=$BTA_NETWORK_DIR/channel-config

export CHANNEL_NAME=global-channel && configtxgen -profile GlobalChannel -outputAnchorPeersUpdate $BTA_NETWORK_DIR/channel-artifacts/PeerO1SuperAdminAnchorGlobalChannel.tx -channelID $CHANNEL_NAME -asOrg PeerO1SuperAdminBtaKilroyMSP

export CHANNEL_NAME=global-channel && configtxgen -profile GlobalChannel -outputAnchorPeersUpdate $BTA_NETWORK_DIR/channel-artifacts/PeerO2AdminAnchorGlobalChannel.tx -channelID $CHANNEL_NAME -asOrg PeerO2AdminBtaKilroyMSP

export CHANNEL_NAME=c1-channel && configtxgen -profile C1Channel -outputAnchorPeersUpdate $BTA_NETWORK_DIR/channel-artifacts/PeerO2AdminAnchorC1Channel.tx -channelID $CHANNEL_NAME -asOrg PeerO2AdminBtaKilroyMSP

export CHANNEL_NAME=c1-channel && configtxgen -profile C1Channel -outputAnchorPeersUpdate $BTA_NETWORK_DIR/channel-artifacts/PeerO3ShAnchorC1Channel.tx -channelID $CHANNEL_NAME -asOrg PeerO3ShBtaKilroyMSP

export CHANNEL_NAME=c1-channel && configtxgen -profile C1Channel -outputAnchorPeersUpdate $BTA_NETWORK_DIR/channel-artifacts/PeerO4MLOpsAnchorC1Channel.tx -channelID $CHANNEL_NAME -asOrg PeerO4MLOpsBtaKilroyMSP

export CHANNEL_NAME=c1-channel && configtxgen -profile C1Channel -outputAnchorPeersUpdate $BTA_NETWORK_DIR/channel-artifacts/PeerO5AIEngineerAnchorC1Channel.tx -channelID $CHANNEL_NAME -asOrg PeerO5AIEngineerBtaKilroyMSP

export CHANNEL_NAME=o5-ai-engineer-channel && configtxgen -profile O5AIEngineerChannel -outputAnchorPeersUpdate $BTA_NETWORK_DIR/channel-artifacts/PeerO5AIEngineerAnchorAIChannel.tx -channelID $CHANNEL_NAME -asOrg PeerO5AIEngineerBtaKilroyMSP

echo -e "${Green}"
echo "-----------------------------------------------------------------------"
echo "-----------------------------------------------------------------------"
echo "Successfully generated anchor peer configuration file"
echo "-----------------------------------------------------------------------"
echo "-----------------------------------------------------------------------"
echo -e "${Color_Off}"