#!/bin/bash

set -e

JAR_FILE="server.jar"
WORLD_DIR="worlds"

echo "=== Minecraft Server Launcher ==="
echo "1) Load existing world"
echo "2) Create new world"
echo "3) Exit"
read -p "Choose an option: " choice

case "$choice" in
    1)
        if [ ! -d "$WORLD_DIR" ]; then
            echo "No existing world found! Please create one first."
            exit 1
        fi
        echo "Starting server with existing world..."
        java -Xmx1024M -Xms1024M -jar "$JAR_FILE" nogui
        ;;
    2)
        read -p "Enter new world name: " new_world
        if [ -z "$new_world" ]; then
            echo "World name cannot be empty!"
            exit 1
        fi
        echo "Creating new world '$new_world'..."
        rm -rf "$WORLD_DIR"
        mkdir "$WORLD_DIR"
        java -Xmx1024M -Xms1024M -jar "$JAR_FILE" nogui
        ;;
    3)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac
