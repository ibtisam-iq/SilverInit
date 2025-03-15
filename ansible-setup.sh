#!/bin/bash

# SilverInit - Ansible Setup
# -------------------------------------------------
# This script installs Ansible on Ubuntu or Linux Mint.


# Exit immediately if a command fails
set -e  

# Ensure the script is running on Ubuntu or Linux Mint
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]; then
        echo -e "\n✅ Detected supported OS: $NAME ($ID)"
    else
        echo -e "\n❌ This script is only for Ubuntu & Linux Mint. Exiting...\n"
        exit 1
    fi
else
    echo -e "\n❌ Unable to determine OS type. Exiting...\n"
    exit 1
fi

# Check if Ansible is already installed
if command -v ansible &> /dev/null; then
    echo -e "\n✅ Ansible is already installed. Version:\n$(ansible --version)\n"
    exit 0
fi

# Install dependencies
echo -e "\n🚀 Installing dependencies...\n"
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
    echo -e "✅ Ansible installed successfully. Version:\n$(ansible --version)\n"
else
    echo -e "\n❌ Ansible installation failed. Exiting...\n"
    exit 1
fi