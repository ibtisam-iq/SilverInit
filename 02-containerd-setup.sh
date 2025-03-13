#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is running on Ubuntu
[[ -f /etc/os-release ]] && . /etc/os-release
if [[ "$ID" != "ubuntu" ]]; then
    echo "This script is for Ubuntu only."
    exit 1
fi

# Update and install necessary dependencies
echo "Updating system and installing dependencies..."
sudo apt update -qq && sudo apt install -yq ca-certificates curl jq

# Add Containerd repository
echo "Adding Docker repository for installing containerd..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -qq

# Install containerd
echo "Installing container runtime (containerd)..."
sudo apt-get install -y containerd.io

# Check containerd.service
echo "Verify the path of the containerd service file"
sudo systemctl show -p FragmentPath containerd

# Configure containerd
echo "Configuring containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
if grep -q 'SystemdCgroup = false' /etc/containerd/config.toml; then
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
fi
grep 'SystemdCgroup' /etc/containerd/config.toml

# Create directory for CNI plugins
echo "Creating directory for CNI plugins..."
sudo mkdir -p /opt/cni/bin

# Download latest CNI plugins
echo "Downloading latest CNI plugins..."
CNI_VERSION=$(curl -s https://api.github.com/repos/containernetworking/plugins/releases/latest | jq -r '.tag_name')
wget "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz"

# Extract CNI plugins
echo "Extracting CNI plugins..."
sudo tar -C /opt/cni/bin -xzvf cni-plugins-linux-amd64-${CNI_VERSION}.tgz

# See if CNI plugins are installed correctly
echo "Checking CNI plugins installation..."
sudo ls /opt/cni/bin/

# Restart containerd to detect CNI plugins
echo "Restarting containerd to load CNI plugins..."
sudo systemctl enable containerd --now
sudo systemctl restart containerd

# Verify containerd status
echo "Verifying containerd status..."
sudo ss -l | grep containerd

# Pull Alpine image to test containerd
echo "Pulling Alpine image to test containerd..." 
sudo ctr images pull docker.io/library/alpine:latest

# Check containerd and runc versions
echo "Containerd version: $(containerd --version | awk '{print $3}')"
echo "Runc version: $(runc --version | awk '{print $3}')"

echo "containerd and CNI plugins setup completed successfully!"

echo "====================================="
