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

# Start Playit
echo "[INFO] Starting Playit tunnel..."
playit &
PLAYIT_PID=$!
sleep 3

# Start Minecraft server
echo "[INFO] Starting Minecraft server..."
$JAVA_CMD

# Stop Playit after Minecraft server stops
echo "[INFO] Stopping Playit tunnel..."
kill $PLAYIT_PID 2>/dev/null
