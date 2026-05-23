#!/bin/bash
set -e

apt-get update -y
apt-get install -y curl git python3 python3-pip

# Install iii
curl -fsSL https://install.iii.dev/iii/main/install.sh | sh
export PATH=$PATH:/root/.local/bin

# Clone repo
git clone https://github.com/Suryansh0910/alchemyst-devops-assignment.git /opt/quickstart
cd /opt/quickstart

# Create systemd service for inference-worker
cat > /etc/systemd/system/inference-worker.service << 'UNIT'
[Unit]
Description=iii Inference Worker
After=network.target

[Service]
User=root
WorkingDirectory=/opt/quickstart
Environment=III_URL=ws://${gateway_ip}:49134
ExecStart=/root/.local/bin/iii worker start ./workers/inference-worker
Restart=always

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable inference-worker
systemctl start inference-worker
