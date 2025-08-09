#!/data/data/com.termux/files/usr/bin/bash
# =========================================
# Minecraft Vanilla 1.21.1 Server Installer
# For Termux + Playit.gg
# =========================================

set -e

echo "=== Minecraft 1.21.1 Termux Installer ==="

# Step 1: Update packages
echo "[1/6] Updating Termux packages..."
pkg update -y && pkg upgrade -y

# Step 2: Install dependencies
echo "[2/6] Installing dependencies..."
pkg install openjdk-17 git wget unzip -y

# Step 3: Create folder structure
echo "[3/6] Creating project folders..."
mkdir -p server worlds playit

# Step 4: Download Vanilla 1.21.1 server jar from Mojang
SERVER_JAR_URL="https://piston-data.mojang.com/v1/objects/c9ad8fa9e8aabc3919f309d854601df7cfccba54/server.jar"
if [ ! -f server/server.jar ]; then
    echo "[4/6] Downloading Minecraft 1.21.1 server jar..."
    wget -O server/server.jar "$SERVER_JAR_URL"
else
    echo "[4/6] Server jar already exists. Skipping download."
fi

# Step 5: Accept EULA
echo "[5/6] Setting up EULA..."
echo "eula=true" > server/eula.txt

# Step 6: Download Playit.gg agent
PLAYIT_DOWNLOAD_URL="https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-arm64"
PLAYIT_BIN="playit/playit"
if [ ! -f "$PLAYIT_BIN" ]; then
    echo "[6/6] Downloading Playit.gg agent..."
    wget -O "$PLAYIT_BIN" "$PLAYIT_DOWNLOAD_URL"
    chmod +x "$PLAYIT_BIN"
else
    echo "[6/6] Playit.gg agent already exists. Skipping download."
fi

# Ask for Playit.gg token
echo ""
echo "=================================================="
echo "  Go to https://playit.gg to create a free account"
echo "  Then click 'Download Agent', copy your claim token"
echo "=================================================="
read -p "Enter your Playit.gg claim token: " PLAYIT_TOKEN

# Save token to config file
echo "{ \"claim_token\": \"$PLAYIT_TOKEN\" }" > playit/playit_config.json

echo ""
echo "=== Installation Complete ==="
echo "Run './start.sh' to launch your Minecraft server."
