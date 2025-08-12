#!/bin/bash

set -e

echo "=== Minecraft Vanilla 1.21.1 Server Setup ==="

# Install dependencies
echo "[1/3] Installing dependencies..."
apt update
apt install -y openjdk-21-jre-headless wget

# Download server jar
echo "[2/3] Downloading Minecraft server (1.21.1)..."
wget -O server.jar "https://piston-data.mojang.com/v1/objects/f3e503a630e3ff92c1b3c1d4d78b810e16a3a836/server.jar"

# Accept EULA
echo "[3/3] Accepting EULA..."
echo "eula=true" > eula.txt

echo "=== Installation Complete! ==="
echo "Run ./start.sh to start your server."
