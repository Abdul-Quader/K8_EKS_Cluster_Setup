#!/bin/bash
eksctl create cluster \
  --name my-eks-cluster \
  --version 1.23  # Specify desired Kubernetes version
  --role-arn arn:aws:iam::<ACCOUNT_ID>:role/eks-cluster-role  # Replace with your IAM role ARN
  --nodegroup-name my-nodegroup \
  --nodes 2  # Number of worker nodes
  --node-type t3.medium  # Instance type for worker nodes
  --vpc <VPC_ID>  # Replace with your VPC ID
  --subnets <SUBNET_ID1>,<SUBNET_ID2>  # Replace with subnet IDs from your VPC
  --region <REGION>  # Replace with your AWS region
