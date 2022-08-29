#!/bin/bash

apt -y update
apt -y install awscli
aws s3 cp s3://${s3_bucket}/gen /home/ubuntu/