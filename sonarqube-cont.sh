#!/bin/bash

# SilverInit - Sonarqube Container Setup Script
# -------------------------------------------------
# This script installs and runs SonarQube container on Linux.

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

# Prompt user for port (default: 9000)
while true; do
    read -rp "🔹 Please enter the port for SonarQube container (Press Enter for default: 9000): " USER_PORT
    USER_PORT=${USER_PORT:-9000}  # Default to 9000 if empty
    if validate_port "$USER_PORT"; then
        break
    fi
done

echo -e "\n✅ Using port: $USER_PORT"

# Run SonarQube with auto-restart enabled
echo -e "\n🚀 Starting SonarQube container..."
docker run -d --name sonarqube -p "$USER_PORT:9000" --restart always sonarqube:lts-community

# Check container status
echo -e "\n🔍 Checking SonarQube status..."
if docker ps --filter "name=sonarqube" --filter "status=running" | grep sonarqube; then
    echo -e "\n✅ SonarQube is running on port $USER_PORT! Access it at: http://$(hostname -I | awk '{print $1}'):$USER_PORT"
else
    echo -e "\n❌ SonarQube failed to start. Restarting..."
    docker restart sonarqube
fi
