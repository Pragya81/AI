#!/bin/bash

# AWS Configuration
AWS_REGION="us-east-1"    # Replace with your desired region
INSTANCE_TYPE="t2.micro"  # Replace with your desired instance type
KEY_PAIR_NAME="your-key-pair-name"   # Replace with your existing key pair name in AWS
SECURITY_GROUP_NAME="ros-security-group"   # Replace with a unique name for the security group

# Create a new security group with SSH and ROS ports open
aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME \
    --description "Security group for ROS instance"

# Allow SSH access from your IP (replace YOUR_IP_ADDRESS with your actual IP)
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME \
    --protocol tcp --port 22 --cidr YOUR_IP_ADDRESS/32

# Allow ROS communication ports (replace YOUR_IP_ADDRESS with your actual IP)
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME \
    --protocol tcp --port 11311 --cidr YOUR_IP_ADDRESS/32

# Launch an EC2 instance with Ubuntu AMI
INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0c55b159cbfafe1f0 \
                --count 1 --instance-type $INSTANCE_TYPE \
                --key-name $KEY_PAIR_NAME --security-groups $SECURITY_GROUP_NAME \
                --region $AWS_REGION --query 'Instances[0].InstanceId' --output text)

echo "Waiting for the instance to start..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
                --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "Public IP Address: $PUBLIC_IP"
