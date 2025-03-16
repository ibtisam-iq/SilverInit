#!/bin/bash

# SilverInit - Terraform Setup
# -------------------------------------------------
# This script installs Terraform on Ubuntu or its derivatives.

# Exit immediately if a command fails
set -e  

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running preflight.sh script to ensure that system meets the requirements ..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }
echo -e "\n✅ System meets the requirements to install Terraform."

# Check if Terraform is already installed
if command -v terraform &> /dev/null; then
    echo -e "\n✅ Terraform is already installed. Version:\n$(terraform --version)\n"
    exit 0
fi

# Update system and install required dependencies
echo -e "\n🚀 Updating package list and checking required dependencies..."
sudo apt update -qq && sudo apt install -yq software-properties-common lsb-release gnupg > /dev/null 2>&1

DEPS=("curl" "wget")

for pkg in "${DEPS[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
        echo -e "🔹 Installing missing dependency: $pkg..."
        sudo apt-get install -yq "$pkg" > /dev/null 2>&1
    else
        echo -e "✅ $pkg is already installed."
    fi
done

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