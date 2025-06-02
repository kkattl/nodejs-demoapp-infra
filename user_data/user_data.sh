#!/bin/bash
set -euo pipefail

OS_RELEASE=$(cat /etc/os-release | grep -oE '^NAME="Amazon Linux [0-9]+"' || true)

if [[ $OS_RELEASE == *"Amazon Linux 2"* ]]; then
  amazon-linux-extras install docker -y
else
  yum install -y docker
fi

systemctl enable --now docker
usermod -aG docker ec2-user

DOCDB_PASS=$(aws secretsmanager get-secret-value \
  --secret-id "/demoapp/dev/docdb/master-pwd" \
  --query SecretString --output text)

export MONGODB_URI="mongodb://appuser:$${DOCDB_PASS}@${docdb_endpoint}:27017/?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"

docker run -d --restart unless-stopped --name demoapp \
  -e MONGODB_URI="$${MONGODB_URI}" \
  -p 3000:3000 ghcr.io/benc-uk/nodejs-demoapp:latest