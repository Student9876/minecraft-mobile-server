#!/data/data/com.termux/files/usr/bin/bash

# Exit on error
set -e

echo "[1/5] Updating packages..."
pkg update -y
pkg upgrade -y

echo "[2/5] Installing dependencies..."
pkg install openjdk-17 wget unzip -y

echo "[3/5] Creating folders..."
mkdir -p server worlds

echo "[4/5] Downloading Minecraft 1.21.1 server.jar..."
wget -O server/server.jar https://piston-data.mojang.com/v1/objects/4ef9e8c9cc58d53c5ccf0c4f08b28a4db4a73ab8/server.jar

echo "[5/5] Accepting EULA..."
echo "eula=true" > server/eula.txt

echo "✅ Installation complete! Use ./start.sh to run your server."
