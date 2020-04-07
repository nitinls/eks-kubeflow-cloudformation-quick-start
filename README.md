# eks-kubeflow-cloudformation-quick-startv1 -

This repo can be used for building a Windows Bastion Host which can be used to access Anonymous KubeFlow Dashboard (in case you are using Non-Cognito kfctl YAML).

Currently runs only in Ohio. CF will be modified to support more regions in near future. 
The scripts used in this repo are referenced from https://eksworkshop.com and https://sagemaker.readthedocs.io/en/stable/amazon_sagemaker_operators_for_kubernetes.html

Steps#

1) Create a new Key-pair in AWS Console. 
2) Execute the Cloudformation template cfv1 (we will need the key-pair from the first step).
3) The cfv1 will run for about 30 minutes and will setup a Linux Jump Box/Bastion Host VM with eksctl and kubectl , setup EKS, KubeFlow and Sagemaker operators for k8s. A Windows Jump Box will also be provisioned in the EKS subnet which is whitelisted to access the KubeFlow Dashboard with anonymous auth.




#Draft Deletion/Roll-Back steps-

1) eksctl delete cluster (eksworkshop-eksctlv10)
2) Delete IAM OIDC
3) Delete IAM Role (eksworkshopv10)
4) Delete ALB 
5) Delete ALB Target Group.
6) Delete the EC2 Key pair
7) Delete/Disable the AWS KMS Custom Key (optional)
8) Delete the Cloudformations (if there are errors)
9) Delete the main Cloudformation which stood up VM.
