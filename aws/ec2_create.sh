#!/usr/bin/bash
# --key-name: Create AWS EC2 "Key pairs" called "gogophish-ssh"
# --security-groups-ids: Create AWS EC2 security group. This is optional, but good for restricting SSH and Admin page access. 


aws ec2 run-instances \
        --region us-east-2 \
        --image-id ami-07efac79022b86107 \
        --count 1 \
        --instance-type t2.micro \
        --key-name gogophish-ssh \
        --security-group-ids sg-xxxx \
        --output json > gophish_ec2.json &&

ec2=$(cat gophish_ec2.json | grep InstanceId | cut -d '"' -f 4)

# Getting the EC2 Public IP
pubIP=$(aws ec2 describe-instances --region us-east-2 --instance-ids $ec2 | grep PublicIpAddress | cut -d '"' -f 4)

echo "[+] AWS EC2 Created!"
echo "[+] AWS EC2 InstanceId: $ec2"
echo "[+] AWS EC2 Public IP: $pubIP"
