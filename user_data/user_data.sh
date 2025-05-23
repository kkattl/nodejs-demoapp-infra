#!/bin/bash
set -euo pipefail

OS_RELEASE=$(cat /etc/os-release | grep -oE '^NAME="Amazon Linux [0-9]+"' || true)

if [[ $OS_RELEASE == *"Amazon Linux 2"* ]]; then
  amazon-linux-extras install docker -y
else
  # Amazon Linux 2023
  yum install -y docker
fi

systemctl enable --now docker
usermod -aG docker ec2-user


docker run -d --restart unless-stopped --name demoapp \
  -p 3000:3000 ghcr.io/benc-uk/nodejs-demoapp:latest

