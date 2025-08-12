#!/bin/bash

# ===== CONFIG =====
JAR_FILE="server.jar"
WORLD_DIR="world"
JAVA_CMD="java -Xmx1G -Xms1G -jar $JAR_FILE nogui"
# ===================

echo "==== Minecraft Server Starter ===="
echo "1) Use existing world"
echo "2) Create new world"
read -p "Select an option [1/2]: " choice

if [ "$choice" == "2" ]; then
    echo "[INFO] Creating new world..."
    rm -rf "$WORLD_DIR"
    mkdir "$WORLD_DIR"
    echo "[INFO] World folder reset. A new world will be generated on first start."
fi

# Accept EULA automatically
if [ ! -f eula.txt ]; then
    echo "[INFO] Accepting EULA..."
    echo "eula=true" > eula.txt
fi

# Check server jar exists
if [ ! -f "$JAR_FILE" ]; then
    echo "[ERROR] $JAR_FILE not found!"
    exit 1
fi

# Start playit in a new Termux session
echo "[INFO] Starting Playit tunnel in new Termux session..."
termux-session create -n "PlayitTunnel" "playit" &
sleep 2

# Start Minecraft server in another new Termux session
echo "[INFO] Starting Minecraft server in new Termux session..."
termux-session create -n "MinecraftServer" "$JAVA_CMD" &
sleep 2

echo "[SUCCESS] Both Playit and Minecraft server are running in separate Termux sessions."
echo "You can switch sessions using Termux's session menu."
