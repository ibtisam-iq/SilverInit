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

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo -e "\n✅ Docker is already installed.\n"
    echo "🔹 Docker version: $(docker --version | awk '{print $3}' | sed 's/,//')"
    exit 0
fi


# Update system and install required dependencies
echo -e "\n🚀 Updating package list and checking required dependencies..."
sudo apt update -qq && sudo apt install -yq ca-certificates > /dev/null 2>&1

DEPS=("curl" "wget")

for pkg in "${DEPS[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
        echo -e "🔹 Installing missing dependency: $pkg..."
        sudo apt-get install -yq "$pkg" > /dev/null 2>&1
    else
        echo -e "✅ $pkg is already installed."
    fi
done


# Install Docker
echo -e "\n🚀 Adding Docker's official GPG key...\n"   
sudo install -m 0755 -d /etc/apt/keyrings 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo -e "\n🚀 Adding Docker repository for installing Docker...\n"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "\n🚀 Installing Docker ...\n"
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugins > /dev/null 2>&1

# Add Jenkins user to the Docker group
sudo usermod -aG docker $USER

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