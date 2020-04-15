#!/bin/bash
# Setup Cloud9 on our Jump Server

#Intall Node.Js
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash

. ~/.bashrc

nvm install node

#Install Dev Tools

sudo yum -y groupinstall "Development Tools"

# Install Cloud9

curl -L https://raw.githubusercontent.com/c9/install/master/install.sh | bash
wget -O - https://raw.githubusercontent.com/c9/install/master/install.sh | bash
