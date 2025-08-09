#!/data/data/com.termux/files/usr/bin/bash
# =========================================
# Minecraft Vanilla 1.21.1 Starter Script
# For Termux + Playit.gg
# =========================================

set -e

# Paths
SERVER_DIR="server"
WORLDS_DIR="worlds"
PLAYIT_DIR="playit"
PLAYIT_BIN="$PLAYIT_DIR/playit"
PLAYIT_CONFIG="$PLAYIT_DIR/playit_config.json"
MC_JAR="$SERVER_DIR/server.jar"

# Make sure everything exists
if [ ! -f "$MC_JAR" ]; then
    echo "ERROR: Server jar not found. Please run ./install.sh first."
    exit 1
fi

if [ ! -f "$PLAYIT_BIN" ] || [ ! -f "$PLAYIT_CONFIG" ]; then
    echo "ERROR: Playit agent or config not found. Please run ./install.sh first."
    exit 1
fi

# Function to select or create world
select_world() {
    echo "=== Minecraft World Selection ==="
    echo "1) Create a new world"
    echo "2) Use existing world"
    read -p "Select option (1 or 2): " choice

    if [ "$choice" = "1" ]; then
        read -p "Enter new world name: " WORLD_NAME
        mkdir -p "$WORLDS_DIR/$WORLD_NAME"
        echo "level-name=$WORLD_NAME" > "$SERVER_DIR/server.properties"
    elif [ "$choice" = "2" ]; then
        echo "Available worlds:"
        ls "$WORLDS_DIR"
        read -p "Enter existing world name: " WORLD_NAME
        if [ ! -d "$WORLDS_DIR/$WORLD_NAME" ]; then
            echo "ERROR: World not found!"
            exit 1
        fi
        echo "level-name=$WORLD_NAME" > "$SERVER_DIR/server.properties"
    else
        echo "Invalid choice."
        exit 1
    fi
}

# Ask to select world
select_world

# Start Playit.gg tunnel in background
echo "Starting Playit.gg tunnel..."
$PLAYIT_BIN -c "$PLAYIT_CONFIG" > "$PLAYIT_DIR/playit.log" 2>&1 & 
PLAYIT_PID=$!

# Give Playit some time to connect
sleep 5

# Try to extract the public address from playit log
PLAYIT_ADDR=$(grep -oE "[0-9a-z]+\.playit\.gg:[0-9]+" "$PLAYIT_DIR/playit.log" | head -n 1)
if [ -n "$PLAYIT_ADDR" ]; then
    echo "Your server is publicly available at: $PLAYIT_ADDR"
else
    echo "Could not detect Playit address. Check $PLAYIT_DIR/playit.log"
fi

# Move into server directory to start MC server
cd "$SERVER_DIR"

echo ""
echo "=== Starting Minecraft Server (CTRL+C to stop) ==="
echo "Type 'stop' in the console to shut down safely."
echo ""

# Run MC server in foreground
java -Xms512M -Xmx1024M -jar server.jar --nogui

# When MC server stops, also stop Playit
echo "Stopping Playit tunnel..."
kill $PLAYIT_PID 2>/dev/null || true

echo "Server stopped."
