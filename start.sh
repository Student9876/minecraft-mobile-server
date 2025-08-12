#!/bin/bash
set -e

SERVER_DIR="/root/mc-server"
SERVER_JAR="$SERVER_DIR/server.jar"
WORLD_DIR="$SERVER_DIR/worlds"

cd "$SERVER_DIR"

echo "============================="
echo "  Minecraft Server Launcher  "
echo "      Vanilla 1.21.1         "
echo "============================="
echo "1) Load existing world"
echo "2) Create new world"
read -p "Choose an option [1-2]: " choice

if [ "$choice" == "1" ]; then
    echo "Available worlds:"
    ls -1 "$WORLD_DIR"
    read -p "Enter world name: " worldname
    if [ ! -d "$WORLD_DIR/$worldname" ]; then
        echo "[!] World not found. Exiting."
        exit 1
    fi
    java -Xmx1G -Xms1G -jar "$SERVER_JAR" nogui --world "$WORLD_DIR/$worldname"

elif [ "$choice" == "2" ]; then
    read -p "Enter new world name: " worldname
    mkdir -p "$WORLD_DIR/$worldname"
    java -Xmx1G -Xms1G -jar "$SERVER_JAR" nogui --world "$WORLD_DIR/$worldname"

else
    echo "[!] Invalid option."
    exit 1
fi
