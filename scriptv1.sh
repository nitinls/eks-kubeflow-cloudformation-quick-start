#!/bin/bash
# Install EKS
# Create Cloud9 workspace with relevant IAM role, remove any local references to credentials.

sudo yum -y install jq gettext bash-completion

export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

export AWS_CLUSTER_NAME=eksworkshop-eksctlv11

aws configure set default.region ${AWS_REGION}
#aws configure set aws_output json

sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
sudo curl --silent --location -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
sudo chmod +x /usr/local/bin/aws-iam-authenticator

/usr/local/bin/kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion

git clone https://github.com/brentley/ecsdemo-frontend.git
git clone https://github.com/brentley/ecsdemo-nodejs.git
git clone https://github.com/brentley/ecsdemo-crystal.git

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin
eksctl version

eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion

ssh-keygen -t rsa -q -P "" -f ~/.ssh/id_rsa-${AWS_CLUSTER_NAME}

aws ec2 import-key-pair --key-name "${AWS_CLUSTER_NAME}" --public-key-material file://~/.ssh/id_rsa-${AWS_CLUSTER_NAME}.pub

aws kms create-alias --alias-name alias/${AWS_CLUSTER_NAME} --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)

export MASTER_ARN=$(aws kms describe-key --key-id alias/${AWS_CLUSTER_NAME} --query KeyMetadata.Arn --output text)

echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile

cat << EOF > ${AWS_CLUSTER_NAME}.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${AWS_CLUSTER_NAME}
  region: ${AWS_REGION}

managedNodeGroups:
- name: nodegroup
  desiredCapacity: 3
  iam:
    withAddonPolicies:
      albIngress: true

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF

eksctl create cluster -f ${AWS_CLUSTER_NAME}.yaml
eksctl utils write-kubeconfig --cluster ${AWS_CLUSTER_NAME}

# Create Windows Jump Box for accessing KubeFlow Dashboard and assign relevant security group for RDP
export EKSWORKSHOP_VPC=$(eksctl get cluster ${AWS_CLUSTER_NAME} | grep vpc | awk  '{print $5}')

export windows_SG=$(aws ec2 create-security-group --group-name windowsSg-${AWS_CLUSTER_NAME} --description "Windows Jump Server security group" --vpc-id ${EKSWORKSHOP_VPC} | jq '.GroupId' | tr -d '"')

aws ec2 authorize-security-group-ingress --group-id ${windows_SG} --protocol tcp --port 3389 --cidr 0.0.0.0/0

export EKSWORKSHOP_SUBNET=$(aws ec2 describe-subnets --filter "Name=tag:kubernetes.io/role/elb, Values=1" | jq '.Subnets[0].SubnetId' | tr -d '"')

aws ec2 run-instances --image-id ami-07f3715a1f6dbb6d9 --count 1 --instance-type t2.large --key-name ${AWS_CLUSTER_NAME} --security-group-ids ${windows_SG} --subnet-id ${EKSWORKSHOP_SUBNET} --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WindowsServer}]'
