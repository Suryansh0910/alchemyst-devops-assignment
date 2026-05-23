#!/bin/bash
set -e

export HOME=/root

# Install dependencies
apt-get update -y
apt-get install -y curl git nodejs npm

# Install iii
curl -fsSL https://install.iii.dev/iii/main/install.sh | sh
export PATH=$PATH:/root/.local/bin

# Clone repo
git clone https://github.com/Suryansh0910/alchemyst-devops-assignment.git /opt/quickstart
cd /opt/quickstart

# Create systemd service for iii engine
cat > /etc/systemd/system/iii-engine.service << 'UNIT'
[Unit]
Description=iii Engine
After=network.target

[Service]
User=root
WorkingDirectory=/opt/quickstart
ExecStart=/root/.local/bin/iii --config config.yaml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

# Create systemd service for caller-worker
cat > /etc/systemd/system/caller-worker.service << 'UNIT'
[Unit]
Description=iii Caller Worker
After=iii-engine.service
Requires=iii-engine.service

[Service]
User=root
WorkingDirectory=/opt/quickstart
ExecStart=/root/.local/bin/iii worker start ./workers/caller-worker
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable iii-engine
systemctl enable caller-worker
systemctl start iii-engine
sleep 10
systemctl start caller-worker
