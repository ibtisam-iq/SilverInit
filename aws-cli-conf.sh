#!/bin/bash

# SilverInit - AWS CLI Installation and Configuration Script
# -------------------------------------------------
# This script installs AWS CLI v2 on Linux and configures it with your AWS credentials.

# Exit immediately if a command fails
set -e

# Ensure the system is running on a 64-bit architecture (x86_64 or amd64)
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then
    echo -e "\n✅ Architecture supported: $ARCH"
else
    echo -e "\n❌ Unsupported architecture: $ARCH. This script only supports x86_64 (amd64). Exiting...\n"
    exit 1
fi

# Uninstall AWS CLI v1 if installed
if command -v aws &>/dev/null; then
    echo -e "\n🔻 Uninstalling AWS CLI v1..."
    sudo apt remove -y awscli
    echo -e "✅ AWS CLI v1 is uninstalled successfully."
fi

# Remove AWS CLI v1 configuration files
if [[ -d "$HOME/.aws" ]]; then
    echo -e "\n🔻 Removing AWS CLI v1 configuration files..."
    rm -rf "$HOME/.aws"
    echo -e "✅ AWS CLI v1 configuration files are removed successfully."
fi

# Install AWS CLI
echo -e "\n🚀 Installing AWS CLI v2..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt update -qq && sudo apt install -yq unzip python3 glibc groff less
unzip awscliv2.zip > /dev/null 2>&1
sudo ./aws/install
rm -rf aws awscliv2.zip aws
echo -e "✅ AWS CLI is installed successfully. Version:\n$(aws --version)"

# Configure AWS CLI
echo -e "\n🔧 Configuring AWS CLI..."
aws configure
echo -e "✅ AWS CLI is installed and configured successfully.\n"