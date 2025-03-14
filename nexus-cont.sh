#!/bin/bash

# SilverInit - Nexus Container Setup Script
# -------------------------------------------------
# This script installs and runs Nexus container on Linux.

# Exit on any error
set -e

# 🛑 Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "\n❌ Docker is NOT installed."
    echo -e "\n🚀 Installing Docker..."
    sudo apt-get update -qq
    sudo apt-get install -yq docker.io
    echo -e "\n✅ Docker installed successfully!"
fi

# ✅ Ensure Docker is running
if ! systemctl is-active --quiet docker; then
    echo -e "\n🔄 Starting Docker..."
    sudo systemctl start docker
    echo -e "\n✅ Docker is now running!"
fi

# Function to validate port
validate_port() {
    local port=$1
    if [[ ! $port =~ ^[0-9]+$ ]] || ((port < 1024 || port > 65535)); then
        echo -e "\n❌ Invalid port! Please enter a number between 1024 and 65535."
        return 1
    fi
    return 0
}

# Prompt user for port (default: 8081)
while true; do
    read -rp "🔹 Enter the port for Nexus container (Press Enter for default: 8081): " USER_PORT
    USER_PORT=${USER_PORT:-8081}  # Default to 8081 if empty
    if validate_port "$USER_PORT"; then
        break
    fi
done

echo -e "\n✅ Using port: $USER_PORT"

# Run Nexus with auto-restart enabled
echo -e "\n🚀 Starting Nexus container..."
docker run -d --name nexus -p "$USER_PORT:8081" --restart always sonatype/nexus3

# Check container status
echo -e "\n🔍 Checking Nexus container status..."
if docker ps --filter "name=nexus" --filter "status=running" | grep nexus; then
    echo -e "\n✅ Nexus is running on port $USER_PORT! Access it at: http://$(hostname -I | awk '{print $1}'):$USER_PORT\n"
    echo -e "\n🔑 Default credentials: $(docker exec nexus cat /nexus-data/admin.password)\n"
    echo -e "\n📌 Note: It may take a few minutes for Nexus container to start completely.\n"
else
    echo -e "\n❌ Nexus failed to start. Restarting..."
    docker restart nexus
fi
