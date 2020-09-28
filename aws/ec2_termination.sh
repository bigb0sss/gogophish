#!/usr/bin/bash
# Version         : 1.0
# Created date    : 09/27/2020
# Last update     : 09/27/2020
# Author          : bigb0ss
# Description     : AWC EC2 Instance Termination

ec2=$(cat gophish_ec2.json | grep InstanceId | cut -d '"' -f 4)

aws ec2 terminate-instances \
        --region us-east-2 \
        --instance-ids $ec2 > /tmp/ec2_termination.log

echo "[+] AWS EC2 Terminated!"
echo "[+] AWS EC2 InstanceId: $ec2"
