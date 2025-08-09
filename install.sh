#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=== Installing Vanilla Minecraft Server 1.21.1 with Playit.gg tunnel ==="

# Step 1: Install required packages
pkg update -y
pkg install -y openjdk-17 wget unzip

# Step 2: Create directories
mkdir -p server
mkdir -p $HOME/playit

# Step 3: Download Minecraft server jar (1.21.1)
echo "Downloading Minecraft server jar..."
wget -O server/server.jar https://piston-data.mojang.com/v1/objects/1d9dcf20eb70e5f163f807e7b50e36c889bd8f9a/server.jar

# Step 4: Accept EULA
echo "eula=true" > server/eula.txt

# Step 5: Download Playit.gg agent
echo "Downloading Playit.gg agent..."
wget -O $HOME/playit/playit https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-arm64

# Step 6: Make Playit executable
chmod +x $HOME/playit/playit

# Step 7: Run Playit.gg agent to get claim token and tunnel URL
echo
echo "=== Installation Complete ==="
echo "Now starting Playit.gg to get your claim token and tunnel URL..."
echo "==============================================================="
echo "NOTE: Copy the URL shown below and open it in your browser to claim."
echo "==============================================================="
$HOME/playit/playit
