#!/bin/bash
set -e

# Install dependencies
apt-get update -y
apt-get install -y curl git nodejs npm

# Install iii
curl -fsSL https://install.iii.dev/iii/main/install.sh | sh
export PATH=$PATH:/root/.local/bin

# Clone repo
git clone https://github.com/Suryansh0910/alchemyst-devops-assignment.git /opt/quickstart
cd /opt/quickstart

# Fix config to bind engine on all interfaces
sed -i 's/host: 127.0.0.1/host: 0.0.0.0/' config.yaml

# Create systemd service for engine
cat > /etc/systemd/system/iii-engine.service << 'UNIT'
[Unit]
Description=iii Engine
After=network.target

[Service]
User=root
WorkingDirectory=/opt/quickstart
ExecStart=/root/.local/bin/iii --config config.yaml
Restart=always

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

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable iii-engine
systemctl enable caller-worker
systemctl start iii-engine
sleep 10
systemctl start caller-worker
