#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Minecraft + Playit Termux Installer ==="

# Step 1: Move to Termux home directory
cd ~

# Step 2: Clone repo into safe location
if [ ! -d "$HOME/minecraft-termux" ]; then
    echo "Cloning repository..."
    git clone https://github.com/Student9876/minecraft-mobile-server.git
fi
cd minecraft-termux

# Step 3: Install dependencies
pkg update -y && pkg upgrade -y
pkg install -y openjdk-17 wget unzip git

# Step 4: Download Minecraft server jar (example: vanilla 1.21.1)
if [ ! -f "server.jar" ]; then
    echo "Downloading Minecraft 1.21.1 server..."
    wget -O server.jar https://piston-data.mojang.com/v1/objects/4e2cbb3bb5b51dfd6a0a0b3d0d5c2af1dd6c50c7/server.jar
fi

# Step 5: Accept EULA
echo "eula=true" > eula.txt

# Step 6: Setup Playit
mkdir -p playit
cd playit
if [ ! -f "playit" ]; then
    echo "Downloading Playit..."
    wget -O playit https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-arm64
    chmod +x playit
fi
cd ..

# Step 7: Run Playit to get claim URL
echo
echo "==============================================================="
echo "Now starting Playit to get your claim token & tunnel URL..."
echo "Copy the URL shown below and open it in your browser to claim."
echo "==============================================================="
./playit/playit
