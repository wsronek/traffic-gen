#!/bin/bash

apt -y update
apt -y install awscli python3-pip
pip3 install locust

aws s3 cp s3://${s3_bucket}/gen /home/ubuntu/

apt -y install 
