#!/bin/bash

# SilverInit - Docker Setup
# -------------------------------------------------
# This script installs Docker on Ubuntu or Linux Mint.
# It installs Docker CE, Docker CLI, Containerd, Docker Buildx, and Docker Compose.

# Safety settings
set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running preflight.sh script to ensure that system meets the requirements to install Docker..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }
echo -e "\n✅ System meets the requirements to install Docker."

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo -e "\n✅ Docker is already installed.\n"
    echo "🔹 Docker version: $(docker --version | awk '{print $3}' | sed 's/,//')"
    exit 0
fi


# Update system and install required dependencies
echo -e "\n🚀 Updating package list and checking required dependencies to install Docker..."
sudo apt update -qq && sudo apt install -yq ca-certificates > /dev/null 2>&1

DEPS=("curl" "wget")

for pkg in "${DEPS[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
        echo -e "\n🔹 Installing missing dependency: $pkg..."
        sudo apt-get install -yq "$pkg" > /dev/null 2>&1
    else
        echo -e "\n✅ $pkg is already installed."
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
sudo apt-get update -qq
sudo apt-get install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1

# Add Jenkins user to the Docker group
sudo usermod -aG docker $USER
echo -e "\n🚀 The current user is added to the Docker group...\n"
echo -e "\n🔄 Please run this command to activate the changes to groups, once this script has finished running: newgrp docker\n"

echo -e "\n✅ Docker has been installed successfully.\n"

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
    echo -e "\n✅ Docker is running."
else
    echo -e "\n❌ Docker is NOT running. Starting Docker..."
    sudo systemctl start docker
fi

echo -e "\n✅ Docker installation completed successfully! 🚀\n"