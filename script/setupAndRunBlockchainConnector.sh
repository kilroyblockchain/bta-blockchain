#!/bin/bash

mkdir ../bta-bc-connector

cd ../bta-bc-connector

sudo rm -r bc-connector

git clone https://bitbucket.org/kilroy/bc-connector.git

cd bc-connector && sudo rm -r .git 

cd ..

cp -r bc-connector bta-bc-connector-o1-super-admim

cp -r bc-connector bta-bc-connector-o2-admin

cp -r bc-connector bta-bc-connector-o3-sh

cp -r bc-connector bta-bc-connector-o4-mlops

cp -r bc-connector bta-bc-connector-o5-ai-engineer

sudo rm -r bc-connector

pwd