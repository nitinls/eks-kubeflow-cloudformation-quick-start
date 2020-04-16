#!/bin/bash
# Setup Cloud9 on our Jump Server

#Intall Node.Js
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
source ~/.nvm/nvm.sh
source ~/.bashrc
nvm install node

#Install Node.JS for ec2-user
/bin/su -c "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash" - ec2-user
/bin/su -c "source ~/.nvm/nvm.sh" - ec2-user
/bin/su -c "source ~/.bashrc" - ec2-user
/bin/su -c "nvm install node" - ec2-user

#Install Dev Tools
sudo yum -y groupinstall "Development Tools"

# Install Cloud9

curl -L https://raw.githubusercontent.com/c9/install/master/install.sh | bash
wget -O - https://raw.githubusercontent.com/c9/install/master/install.sh | bash
