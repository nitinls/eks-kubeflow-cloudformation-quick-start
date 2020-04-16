#!/bin/bash
# Setup Cloud9 on our Jump Server

#Intall Node.Js
wget https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh /home/ec2-user/install.sh

export NVM_DIR=/usr/local/bin

bash /home/ec2-user/install.sh

mv /usr/bin/nvm.sh /usr/bin/nvm

source ~/.bashrc

nvm install node

#Install Dev Tools

sudo yum -y groupinstall "Development Tools"

# Install Cloud9

curl -L https://raw.githubusercontent.com/c9/install/master/install.sh | bash
wget -O - https://raw.githubusercontent.com/c9/install/master/install.sh | bash
