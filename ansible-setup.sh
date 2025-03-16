#!/bin/bash

# SilverInit - Ansible Setup
# -------------------------------------------------
# This script installs Ansible on Ubuntu or Linux Mint.


# Exit immediately if a command fails
set -e  

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running preflight.sh script to ensure that system meets the requirements to install Ansible..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }
echo -e "\n✅ System meets the requirements to install Ansible."

# Check if Ansible is already installed
if command -v ansible &> /dev/null; then
    echo -e "\n✅ Ansible is already installed. Version:\n$(ansible --version)\n"
    exit 0
fi

# Install dependencies
echo -e "\n🚀 Installing dependencies to install Ansible...\n"
sudo apt update -qq && sudo apt install -y software-properties-common > /dev/null 2>&1

# Add Ansible PPA and install Ansible
echo -e "\n🚀 Adding Ansible PPA and installing Ansible...\n"
if sudo add-apt-repository --yes --update ppa:ansible/ansible > /dev/null 2>&1; then
    echo -e "✅ Ansible PPA added successfully."
else
    echo -e "\n❌ Failed to add Ansible PPA. Exiting...\n"
    exit 1
fi

if sudo apt update -qq && sudo apt install -y ansible > /dev/null 2>&1; then
    echo -e "\n✅ Ansible installed successfully. Version: $(ansible --version | head -n1 | awk '{print $3}')"
else
    echo -e "\n❌ Ansible installation failed. Exiting...\n"
    exit 1
fi