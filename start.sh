#!/data/data/com.termux/files/usr/bin/bash
set -e

cd ~/minecraft-termux

# Start Minecraft server in background
echo "Starting Minecraft server..."
java -Xmx1024M -Xms1024M -jar server.jar nogui &

# Start Playit to tunnel the server
echo "Starting Playit tunnel..."
./playit/playit
