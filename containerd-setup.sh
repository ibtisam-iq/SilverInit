#!/bin/bash

# SilverInit - Containerd Setup
# -------------------------------------------------
# This script automates the setup of containerd on a Linux system.
# It installs containerd, configures it, and downloads CNI plugins for networking.

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# Ensure the script is running on Ubuntu or Linux Mint
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "linuxmint" ]]; then
        echo -e "\n❌ Unsupported OS: $NAME ($ID). This script is only for Ubuntu/Linux Mint. Exiting...\n"
        exit 1
    fi
    echo -e "\n✅ Detected OS: $NAME ($ID)\n"
else
    echo -e "\n❌ Unable to determine OS type. Exiting...\n"
    exit 1
fi

# Ensure 64-bit architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" || "$ARCH" != "amd64" ]]; then
    echo -e "\n❌ Unsupported architecture: $ARCH. This script supports only x86_64 (amd64). Exiting...\n"
    exit 1
fi
echo -e "\n✅ Architecture supported: $ARCH\n"

# Update system and install required dependencies
echo -e "\n🚀 Updating package list and installing required dependencies...\n"
sudo apt update -qq && sudo apt install -yq ca-certificates curl jq gpg > /dev/null

# Add Docker repository for containerd
echo -e "\n🔹 Adding Docker repository for containerd installation...\n"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -qq

# Install containerd
echo -e "\n🔹 Installing container runtime (containerd)...\n"
sudo apt-get install -yq containerd.io

# Verify containerd service file path
echo -e "\n🔹 Checking containerd service file path...\n"
sudo systemctl show -p FragmentPath containerd

# Configure containerd
echo -e "\n🔹 Configuring containerd...\n"
sudo mkdir -p /etc/containerd
if [[ ! -f /etc/containerd/config.toml ]]; then
    containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
fi
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
grep 'SystemdCgroup' /etc/containerd/config.toml

# Create directory for CNI plugins
echo -e "\n🔹 Ensuring CNI plugins directory exists...\n"
sudo mkdir -p /opt/cni/bin

# Download latest CNI plugins
echo -e "\n🔹 Fetching latest CNI plugin version...\n"
CNI_VERSION=$(curl -s https://api.github.com/repos/containernetworking/plugins/releases/latest | jq -r '.tag_name')
CNI_TARBALL="cni-plugins-linux-amd64-${CNI_VERSION}.tgz"

if [[ ! -f "$CNI_TARBALL" ]]; then
    echo -e "\n🔹 Downloading CNI plugins...\n"
    wget -q "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/${CNI_TARBALL}"
fi

# Extract CNI plugins if downloaded
if [[ -f "$CNI_TARBALL" ]]; then
    echo -e "\n🔹 Extracting CNI plugins...\n"
    sudo tar -C /opt/cni/bin -xzvf "$CNI_TARBALL" > /dev/null
    rm -f "$CNI_TARBALL"
else
    echo -e "\n❌ Failed to download CNI plugins. Exiting...\n"
    exit 1
fi

# Check CNI plugins installation
echo -e "\n🔹 Validating CNI plugin installation...\n"
sudo ls /opt/cni/bin/ || (echo -e "\n❌ CNI plugins not found. Exiting...\n" && exit 1)

# Restart containerd to apply changes
echo -e "\n🔹 Restarting containerd...\n"
sudo systemctl enable containerd --now
sudo systemctl restart containerd

# Verify containerd service
if systemctl is-active --quiet containerd; then
    echo -e "\n✅ Containerd is running successfully.\n"
else
    echo -e "\n❌ Containerd failed to start. Check logs with: sudo journalctl -u containerd --no-pager\n"
    exit 1
fi

# Pull Alpine image to test containerd
echo -e "\n🔹 Pulling Alpine image to test containerd...\n"
sudo ctr images pull docker.io/library/alpine:latest

# Display containerd and runc versions
echo -e "\n✅ Containerd version: $(containerd --version | awk '{print $3}')\n"
echo -e "✅ Runc version: $(runc --version | awk '{print $3}')\n"

echo -e "\n🎉 Containerd and CNI plugins setup completed successfully!\n"
