#!/bin/bash

# ===== CONFIG =====
JAR_FILE="server.jar"
WORLD_DIR="world"
JAVA_MIN_MEM="2G" # Min RAM
JAVA_MAX_MEM="4G" # Max RAM

JAVA_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
-XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \
-XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \
-XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \
-XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem \
-XX:MaxTenuringThreshold=1"

JAVA_CMD="java $JAVA_FLAGS -Xms$JAVA_MIN_MEM -Xmx$JAVA_MAX_MEM -jar $JAR_FILE nogui"
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
echo "[INFO] Starting Minecraft server with $JAVA_MIN_MEM–$JAVA_MAX_MEM RAM..."
$JAVA_CMD

# Stop Playit after Minecraft server stops
echo "[INFO] Stopping Playit tunnel..."
kill $PLAYIT_PID 2>/dev/null
