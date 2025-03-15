#!/bin/bash

# SilverInit - AWS CLI Installation and Configuration Script
# -------------------------------------------------
# This script installs AWS CLI v2 on Linux and configures it with your AWS credentials.
# It also removes any existing AWS CLI v1 configuration files.

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

# Check if AWS CLI is installed
if command -v aws &>/dev/null; then
    AWS_VERSION=$(aws --version 2>/dev/null | awk '{print $1}' | cut -d'/' -f2 | cut -d'.' -f1)
    
    if [[ "$AWS_VERSION" == "1" ]]; then
        echo -e "\n🔻 Uninstalling AWS CLI v1..."
        sudo apt remove -y awscli
        echo -e "✅ AWS CLI v1 is uninstalled successfully."
    elif [[ "$AWS_VERSION" == "2" ]]; then
        echo -e "\n✅ AWS CLI v2 is already installed. No action needed."
        exit 0  # Exit the script since v2 is already installed
    else
        echo -e "\n⚠️ Unknown AWS CLI version detected: $AWS_VERSION"
        exit 1  # Exit with an error code if the version is unrecognized
    fi
else
    echo -e "\n❌ AWS CLI is not installed."
fi


# Remove AWS CLI v1 configuration files
if [[ -d "$HOME/.aws" ]]; then
    echo -e "\n🔻 Removing AWS CLI v1 configuration files..."
    rm -rf "$HOME/.aws"
    echo -e "✅ AWS CLI v1 configuration files are removed successfully."
fi

# Update system and install required dependencies
echo -e "\n🚀 Updating package list and checking required dependencies..."
sudo apt update -qq

DEPS=("unzip" "python3" "groff" "less")

for pkg in "${DEPS[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
        echo -e "🔹 Installing missing dependency: $pkg..."
        sudo apt-get install -yq "$pkg" > /dev/null 2>&1
    else
        echo -e "✅ $pkg is already installed."
    fi
done

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