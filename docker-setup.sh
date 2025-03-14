#!/bin/bash

# SilverInit - Docker Setup
# -------------------------------------------------
# This script installs Docker on Ubuntu or Linux Mint.
# It installs Docker CE, Docker CLI, Containerd, Docker Buildx, and Docker Compose.

# Exit immediately if a command fails
set -e  

# Ensure the script is running on Ubuntu or Linux Mint
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]; then
        echo -e "\n✅ Detected supported OS: $NAME ($ID)"
    else
        echo -e "\n❌ This script is only for Ubuntu or Linux Mint. Exiting...\n"
        exit 1
    fi
else
    echo -e "\n❌ Unable to determine OS type. Exiting...\n"
    exit 1
fi

# Install Docker
echo -e "\n🚀 Updating packages  ...\n"
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y ca-certificates curl wget openjdk-17-jdk-headless > /dev/null 2>&1
sudo install -m 0755 -d /etc/apt/keyrings 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "\n🚀 Installing Docker ...\n"
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1

# Add Jenkins user to the Docker group
sudo usermod -aG docker jenkins

# Open a new shell for 'newgrp docker' without stopping script execution
echo -e "\n🔄 Applying group changes for 'docker' (without logging out)..."
sg docker -c "echo '✅ Docker group applied successfully!'"
echo -e "\n✅ Docker installed and Jenkins user added to Docker group.\n"

# Enable & Start Jenkins
sudo systemctl enable docker > /dev/null 2>&1
sudo systemctl restart docker > /dev/null 2>&1

# Display Docker Versions
echo -e "\n📌 Installed Docker Components:\n"
echo "🔹 Docker version: $(docker --version | awk '{print $3}' | sed 's/,//')"
echo "🔹 Containerd version: $(containerd --version | awk '{print $3}')"
echo "🔹 Runc version: $(runc --version | awk '{print $3}')"

# Ensure Docker is Running
if systemctl is-active --quiet docker; then
    echo "✅ Docker is running."
else
    echo "❌ Docker is NOT running. Starting Docker..."
    sudo systemctl start docker
fi

echo -e "\n✅ Docker installation completed successfully! 🚀\n"