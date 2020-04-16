# eks-kubeflow-cloudformation-quick-start -

# Why?

For people who wish to start using KubeFlow and Sagemaker operators for Kubernetes without spending any time on installation of underlying infrastructure and tools can use the CloudFormation in this git repo and follow the steps mentioned below in documentation. 

# Steps#

1) Create a new Key-pair in AWS Console. 

2) Execute the Cloudformation template cfv1 (we will need the key-pair from the first step).

3) The cfv1 will run for about 30 minutes and will setup 
        1. a Linux Jump Box with eksctl and kubectl
        2. setup EKS, KubeFlow and Sagemaker operators for k8s. 
        3. install Cloud9 components

4) Connect to the Linux Jump Box from Cloud9 for accessing Kubeflow dashboard.

# Draft Deletion/Roll-Back steps-

1) eksctl delete cluster (eksworkshop-eksctlv10)
2) Delete IAM OIDC
3) Delete IAM Role (eksworkshopv10)
4) Delete ALB 
5) Delete ALB Target Group.
6) Delete the EC2 Key pair
7) Delete/Disable the AWS KMS Custom Key (optional)
8) Delete the Cloudformations (if there are errors)
9) Delete the main Cloudformation which stood up VM.
