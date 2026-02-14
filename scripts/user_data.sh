#!/bin/bash

# ------------------------------------------------------------------
# Author: Marjan Rafi
# Description: Bootstraps an Immutable Web Server with Docker & Nginx
# Note: Designed for Ubuntu 22.04 / 24.04 LTS
# ------------------------------------------------------------------

# --- 1. ERROR HANDLING & LOGGING (CRITICAL) ---
# 'set -e' stops the script immediately if any command fails.
set -e

# Redirect all output (stdout and stderr) to a log file AND the console.
# This is vital because we don't have SSH. We can check this log via
# AWS System Log if something breaks.
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "🚀 [BOOTSTRAP] Starting immutable server setup..."

# --- 2. SYSTEM UPDATES ---
echo "🔄 [UPDATE] Refreshing package lists..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg

# --- 3. INSTALL DOCKER ENGINE ---
echo "🐳 [DOCKER] Installing Docker..."
# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker to start on boot
systemctl enable docker
systemctl start docker

# --- 4. DEPLOY APPLICATION ---
echo "📦 [APP] Deploying Nginx container..."

# Create a custom HTML file to PROVE this is our server
mkdir -p /var/www/html
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Marjan's Immutable Server</title>
    <style>
        body { font-family: sans-serif; text-align: center; padding-top: 50px; background-color: #f0f2f5; }
        h1 { color: #333; }
        .badge { background: #28a745; color: white; padding: 10px 20px; border-radius: 5px; font-weight: bold; }
    </style>
</head>
<body>
    <h1>🚀 Automation Successful!</h1>
    <p>This server was bootstrapped automatically using Terraform & User Data.</p>
    <br>
    <span class="badge">SSH IS DISABLED</span>
</body>
</html>
EOF

# Run Nginx and map Port 80 -> Container Port 80
# We mount our custom HTML file into the container
docker run -d \
  --name web-server \
  --restart always \
  -p 80:80 \
  -v /var/www/html:/usr/share/nginx/html \
  nginx:alpine

# --- 5. FINALIZE ---
echo "✅ [SUCCESS] Bootstrap complete. Web server is running."