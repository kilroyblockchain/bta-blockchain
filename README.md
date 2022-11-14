# bta-blockchain
Blockchain Tethered AI

Clear all the nodes

```
cd script

sh removeCertificates.sh
sh removeArtifacts.sh
sh stopNodes.sh
```

```
First:
Generate certificate files:
sh generateCertificates.sh

Generate genesis.block file inside bta-network/channel-artifacts
sh generateGenesisBlock.sh

Generate channel configuration files inside bta-network/channel-artifacts
sh generateChannelConfiguration.sh

Generate anchor peer configuration files inside bta-network/channel-artifacts
sh generateAnchorPeer.sh

```

```
Run Nodes
sh runNodes.sh

Create CHannel
sh createChannel.sh

Join Channel
sh joinChannels.sh

Add Anchor Peer
sh addAnchorPeer.sh
```
