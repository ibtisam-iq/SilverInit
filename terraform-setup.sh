#!/bin/bash

# SilverInit - Terraform Setup
# -------------------------------------------------
# This script installs Terraform on Ubuntu or its derivatives.

# Exit immediately if a command fails
set -e  

# Ensure the script is running on Ubuntu or Linux Mint or Debian
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" || "$ID" == "debian" ]]; then
        echo -e "\n✅ Detected supported OS: $NAME ($ID)"
    else
        echo -e "\n❌ This script is only for Ubuntu & its derivatives. Exiting...\n"
        exit 1
    fi
else
    echo -e "\n❌ Unable to determine OS type. Exiting...\n"
    exit 1
fi

# Install dependencies
echo -e "\n🚀 Installing dependencies...\n"
sudo apt update -qq && sudo apt install -y gnupg software-properties-common curl lsb-release > /dev/null 2>&1

# Add HashiCorp GPG key and repository
if wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; then
    echo -e "\n✅ HashiCorp GPG key added successfully."
else
    echo -e "\n❌ Failed to add HashiCorp GPG key. Exiting...\n"
    exit 1
fi

if echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null; then
    echo -e "✅ HashiCorp repository added successfully."
else
    echo -e "\n❌ Failed to add HashiCorp repository. Exiting...\n"
    exit 1
fi

# Install Terraform
echo -e "\n🚀 Installing Terraform...\n"
if sudo apt update -qq && sudo apt install -y terraform > /dev/null 2>&1; then
    echo -e "✅ Terraform installed successfully. Version:\n$(terraform --version)"
else
    echo -e "\n❌ Terraform installation failed. Exiting...\n"
    exit 1
fi