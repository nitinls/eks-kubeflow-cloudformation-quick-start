# eks-kubeflow-cloudformation-quick-start -

# Why?

For people who wish to start using KubeFlow and Sagemaker operators for Kubernetes without spending any time on installation of underlying infrastructure and tools can use the CloudFormation in this git repo and follow the steps mentioned below in documentation.

# Steps#

1) Clone the git repo locally on your workstation and execute the Cloudformation template (we assume that you have already setup awscli)

aws cloudformation create-stack --stack-name myteststack --template-body file://cfv1.json --capabilities CAPABILITY_IAM

You can also use AWS Console to run the Cloudformation template.

2) The cfv1 will run for about 30 minutes and will setup
        a) A Linux Jump Box with eksctl and kubectl
        b) EKS, KubeFlow and Sagemaker operators for k8s.
        c) install Cloud9 components

You can watch the installation process by logging into the Linux Jump Server (using EC2 instance connect) and tailing the log file at /var/log/cloud-init-output.log.

3) Connect to the Linux Jump Box from Cloud9 for accessing Kubeflow dashboard.

# Deletion/Roll-Back steps-

1) eksctl delete cluster
2) Delete IAM OIDC
3) Delete IAM Role (eksworkshopv10)
4) Delete ALB
5) Delete ALB Target Group.
6) Delete the EC2 Key pair
7) Delete/Disable the AWS KMS Custom Key (optional)
8) Delete the Cloudformations (if there are errors)
9) Delete the main Cloudformation which stood up VM.
