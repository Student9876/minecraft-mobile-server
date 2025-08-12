#!/data/data/com.termux/files/usr/bin/bash

cd server

echo "Select an option:"
echo "1) Use existing world"
echo "2) Create a new world"
read -p "Enter choice [1-2]: " choice

if [ "$choice" == "1" ]; then
    read -p "Enter the name of the world folder (from ../worlds): " world_name
    if [ -d "../worlds/$world_name" ]; then
        cp -r ../worlds/$world_name ./world
        echo "Loaded existing world: $world_name"
    else
        echo "World not found. Exiting..."
        exit 1
    fi
elif [ "$choice" == "2" ]; then
    rm -rf world
    echo "A new world will be generated on first server start."
else
    echo "Invalid choice."
    exit 1
fi

echo "Starting Minecraft server..."
java -Xmx1024M -Xms1024M -jar server.jar nogui
