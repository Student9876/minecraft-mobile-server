#!/bin/bash

# ==============================
#  Minecraft Server + Playit
#  Vanilla 1.21.1 - Single Terminal
# ==============================

JAR_FILE="server.jar"
WORLD_DIR="world"
PLAYIT_CONFIG="playit.toml"

# Check for server.jar
if [ ! -f "$JAR_FILE" ]; then
    echo "[ERROR] $JAR_FILE not found! Please place it in the repo folder."
    exit 1
fi

# Check for world folder
if [ ! -d "$WORLD_DIR" ]; then
    echo "[WARNING] World folder not found. A new world will be created."
fi

# Check for playit config
if [ ! -f "$PLAYIT_CONFIG" ]; then
    echo "[ERROR] $PLAYIT_CONFIG not found! Please add your Playit config."
    echo "You can download it from https://playit.gg/account/settings"
    exit 1
fi

# Start Playit in background
echo "[INFO] Starting Playit tunnel..."
playit --config "$PLAYIT_CONFIG" &
PLAYIT_PID=$!

# Wait a moment to ensure tunnel starts
sleep 3
echo "[INFO] Playit started (PID: $PLAYIT_PID)"

# Start Minecraft server
echo "[INFO] Starting Minecraft server..."
java -Xmx1024M -Xms1024M -jar "$JAR_FILE" nogui

# Stop Playit after server stops
echo "[INFO] Stopping Playit..."
kill $PLAYIT_PID
