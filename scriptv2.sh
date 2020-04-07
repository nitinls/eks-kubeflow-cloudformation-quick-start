#!/bin/bash
#Install KubeFlow on EKS

export AWS_CLUSTER_NAME=eksworkshop-eksctlv11
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')


kubectl get nodes # if we see our 3 nodes, we know we have authenticated correctly

STACK_NAME=$(eksctl get nodegroup --cluster ${AWS_CLUSTER_NAME} -o json | jq -r '.[].StackName')
ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile

export NODEGROUP_NAME=$(eksctl get nodegroups --cluster ${AWS_CLUSTER_NAME} -o json | jq -r '.[0].Name')
eksctl scale nodegroup --cluster ${AWS_CLUSTER_NAME} --name $NODEGROUP_NAME --nodes 6

curl --silent --location "https://github.com/kubeflow/kfctl/releases/download/v1.0.1/kfctl_v1.0.1-0-gf3edb9b_linux.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/kfctl /usr/local/bin

cat << EoF > kf-install.sh
export AWS_CLUSTER_NAME=eksworkshop-eksctlv11
export KF_NAME=\${AWS_CLUSTER_NAME}

export BASE_DIR=/home/ec2-user/environment
export KF_DIR=\${BASE_DIR}/\${KF_NAME}

# export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_aws_cognito.v1.0.1.yaml"
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_aws.v1.0.1.yaml"

export CONFIG_FILE=\${KF_DIR}/kfctl_aws.yaml
EoF

source kf-install.sh

mkdir -p ${KF_DIR}
cd ${KF_DIR} && wget -O kfctl_aws.yaml $CONFIG_URI

sed -i '/region: us-west-2/ a \      enablePodIamPolicy: true' ${CONFIG_FILE}

sed -i -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' ${CONFIG_FILE}
sed -i "s@us-west-2@$AWS_REGION@" ${CONFIG_FILE}

sed -i "s@roles:@#roles:@" ${CONFIG_FILE}
sed -i "s@- eksctl-${AWS_CLUSTER_NAME}-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@#- eksctl-${AWS_CLUSTER_NAME}-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@" ${CONFIG_FILE}

curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin

eksctl utils write-kubeconfig --cluster ${AWS_CLUSTER_NAME}
cd ${KF_DIR} && kfctl apply -V -f ${CONFIG_FILE}
kubectl -n kubeflow get all

sleep 120

export SG_ALB=$(aws elbv2 describe-load-balancers | jq '.LoadBalancers[0].SecurityGroups[0]' | tr -d '"')
export windows_SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=*windowsSg-${AWS_CLUSTER_NAME}* | jq '.SecurityGroups[0].GroupId' | tr -d '"')
#export SG_WINDOWS=$(aws ec2 describe-instances --filters "Name=tag-value,Values=Jumpbox" | jq '.Reservations[0].Instances[0].SecurityGroups[0].GroupId' | tr -d '"')
#export windows_SG=$(aws ec2 create-security-group --group-name windowsSg-${AWS_CLUSTER_NAME} --description "Windows Jump Server security group" --vpc-id ${EKSWORKSHOP_VPC} | jq '.GroupId' | tr -d '"')
#aws ec2 run-instances --image-id ami-07f3715a1f6dbb6d9 --count 1 --instance-type t2.large --key-name Amit --security-group-ids sg-03ecce0af6f5ab7fa --subnet-id subnet-0130b3e1c3b757cff --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WindowsServer1}]' | jq '.Instances[0].PrivateIpAddresses' | tr -d '"'

export windows_pub_ip= $(aws ec2 describe-instances --filters "Name=tag:Name,Values=WindowsServer" | jq '.Reservations[0].Instances[0].PublicIpAddress' | tr -d '"')

aws ec2 authorize-security-group-ingress --group-id ${SG_ALB} --protocol tcp --port 80 --source-group ${windows_pub_ip}/32
aws ec2 revoke-security-group-ingress --group-id ${SG_ALB} --protocol tcp --port 80 --cidr 0.0.0.0/0
