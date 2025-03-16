#!/bin/bash

# ==================================================
# SilverInit - Ansible Setup
# --------------------------------------------------
# This script installs Ansible on Ubuntu or Linux Mint.
# Author: Muhammad Ibtisam Iqbal
# License: MIT
# Version: 1.0
# Usage: sudo bash ansible-setup.sh

# ==================================================

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# ==================================================
# 🛠️ Preflight Check
# ==================================================
echo -e "\n\033[1;34m🚀 Running preflight.sh script to ensure that system meets the requirements to install Ansible...\033[0m"
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo -e "\n\033[1;31m❌ Failed to execute preflight.sh. Exiting...\033[0m"; exit 1; }
echo -e "\n\033[1;32m✅ System meets the requirements to install Ansible.\033[0m"

# ==================================================
# 🔍 Checking for Existing Installation
# ==================================================
if command -v ansible &> /dev/null; then
    echo -e "\n\033[1;32m✅ Ansible is already installed. Skipping Installation ... Happy Automating! 🚀\033[0m"
    echo -e "📌 Installed Version: \033[1;36m$(ansible --version | head -n1 | awk '{print $NF}' | tr -d ']')\033[0m\n"
    exit 0
fi

# ==================================================
# 📦 Installing Dependencies
# ==================================================
echo -e "\n\033[1;34m🚀 Installing dependencies required for Ansible...\033[0m\n"
sudo apt update -qq && sudo apt install -y software-properties-common > /dev/null 2>&1

echo -e "\n\033[1;34m🚀 Adding Ansible PPA Repository...\033[0m\n"
if sudo add-apt-repository --yes --update ppa:ansible/ansible > /dev/null 2>&1; then
    echo -e "\033[1;32m✅ Ansible PPA added successfully.\033[0m"
else
    echo -e "\n\033[1;31m❌ Failed to add Ansible PPA. Exiting...\033[0m\n"
    exit 1
fi

# ==================================================
# 📥 Installing Ansible
# ==================================================
echo -e "\n\033[1;34m🚀 Installing Ansible... Please wait for a few minutes...\033[0m\n"
if sudo apt update -qq && sudo apt install -y ansible > /dev/null 2>&1; then
    echo -e "\n\033[1;32m✅ Ansible installed successfully.\033[0m"
    echo -e "📌 Installed Version: \033[1;36m$(ansible --version | head -n1 | awk '{print $NF}' | tr -d ']')\033[0m\n"
else
    echo -e "\n\033[1;31m❌ Ansible installation failed. Exiting...\033[0m\n"
    exit 1
fi

echo -e "\n\033[1;32m🎉 Ansible setup completed successfully. Happy Automating! 🚀\033[0m\n"

# ==================================================
# ℹ️ CLI Argument Handling (Future Support)
# ==================================================
echo -e "\n\033[1;33m⚠️  If you want CLI argument handling (e.g., -q for quiet mode, --no-update to skip updates), let me know, and I'll add it!\033[0m\n"
