#!/bin/bash

apt -y update
apt -y install awscli python3-pip
pip3 install locust

aws s3 cp s3://${traffic-gen-script-s3-bucket}/traffic-gen /root/traffic-gen.py

for url in ${traffic-gen-urls}; do
  locust -f /root/traffic-gen.py --headless -u 100 -r 10 --host http://$url &
done