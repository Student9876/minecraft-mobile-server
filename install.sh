#!/bin/bash
set -e

echo "[*] Updating packages..."
apt update -y && apt upgrade -y

echo "[*] Installing dependencies..."
apt install -y openjdk-21-jdk wget unzip screen

# Create project folder
mkdir -p /root/mc-server
cd /root/mc-server

# Download Vanilla 1.21.1 server jar
SERVER_JAR="server.jar"
if [ ! -f "$SERVER_JAR" ]; then
    echo "[*] Downloading Minecraft Vanilla 1.21.1..."
    wget -O "$SERVER_JAR" https://piston-data.mojang.com/v1/objects/ea1e2d342774e6a8f3e3f3af18e8a50182c5cc75/server.jar
fi

# Accept EULA
echo "[*] Accepting EULA..."
echo "eula=true" > eula.txt

# Worlds directory
mkdir -p worlds

echo "[*] Installation complete!"
echo "Run your server with:"
echo "java -Xmx1G -Xms1G -jar $SERVER_JAR nogui"
