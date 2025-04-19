#!/bin/bash

# =============================================================
# 🐳 SilverInit - Docker Setup
# -------------------------------------------------------------
# 📌 Description: This script installs Docker on Ubuntu or Linux Mint.
# 📌 Usage      : sudo bash docker-setup.sh [options]
# 📌 Options    :
#   -q           : Quiet mode (no prompts)
#   --no-update  : Skip system update
#   -h | --help  : Show this help menu
#
# 📌 Author     : Muhammad Ibtisam Iqbal
# 📌 Version    : 1.0.0
# 📌 License    : MIT
# =============================================================

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR  # Handle script failures

# -------------------------------
# 🛠️ Configuration
# -------------------------------
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"
QUIET_MODE=false
SKIP_UPDATE=false

# Colors for better readability
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# -------------------------------
# 🏗️ Functions
# -------------------------------

# Print Divider
divider() {
    echo -e "${CYAN}========================================${RESET}"
}

# Log Function (Print & Save to Log File)
log() {
    echo -e "$1"
}

# Show Help Menu
show_help() {
    echo -e "${CYAN}Usage: sudo bash $0 [options]${RESET}"
    echo -e "${YELLOW}Options:${RESET}"
    echo -e "  -q           Quiet mode (no prompts)"
    echo -e "  --no-update  Skip system update"
    exit 0
}

# Parse CLI Arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -q) QUIET_MODE=true ;;
        --no-update) SKIP_UPDATE=true ;;
        -h|--help) show_help ;;
        *) echo "❌ Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# -------------------------------
# 🚀 Preflight Check
# -------------------------------
log "\n🚀 Running preflight check..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { log "❌ Preflight check failed! Exiting..."; exit 1; }
log "✅ Preflight check passed!"

divider

# -------------------------------
# 📦 Install Docker
# -------------------------------

# Skip update if --no-update flag is set
if [[ "$SKIP_UPDATE" == false ]]; then
    log "\n🚀 Updating system and installing dependencies..."
    sudo apt update -qq && sudo apt install -yq curl wget ca-certificates > /dev/null 2>&1
fi

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    log "\n✅ Docker is already installed."
    log "🔹 Docker version: $(docker --version | awk '{print $3}' | sed 's/,//')"
    exit 0
fi

divider

# Install Docker
echo -e "\n🚀 Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 
sudo chmod a+r /etc/apt/keyrings/docker.asc

divider

echo -e "\n🚀 Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

divider

echo -e "\n🚀 Installing Docker..."
sudo apt-get update -qq
sudo apt-get install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1

divider

# -------------------------------
# 🔧 Post-Installation
# -------------------------------

# Add user to Docker group
sudo usermod -aG docker $USER
log "\n🚀 Added the current user to the Docker group."
log "🔄 Please run: newgrp docker to apply changes."

# Enable & Start Docker Service
log "\n🚀 Enabling & Starting Docker Service..."
sudo systemctl enable docker > /dev/null 2>&1
sudo systemctl restart docker > /dev/null 2>&1

divider

# Display Installed Versions
log "\n📌 Installed Docker Components:\n"
log "🔹 Docker version: $(docker --version | awk '{print $3}' | sed 's/,//')"
log "🔹 Containerd version: $(containerd --version | awk '{print $3}')"
log "🔹 Runc version: $(runc --version | awk '{print $3}')"

divider

# Ensure Docker is Running
if systemctl is-active --quiet docker; then
    log "\n✅ Docker is running."
else
    log "\n❌ Docker is NOT running. Starting Docker..."
    sudo systemctl start docker
fi

divider

log "\n✅ Docker installation completed successfully! 🚀"
log "\n🔄 Please run: sudo usermod -aG docker $USER && newgrp docker && docker info"

# ==================================================
# 🎉 Setup Complete! Thank You! 🙌
# ==================================================
echo -e "\n\033[1;33m✨  Thank you for choosing SilverInit - Muhammad Ibtisam 🚀\033[0m\n"
echo -e "\033[1;32m💡 Automation is not about replacing humans; it's about freeing them to be more human—to create, innovate, and lead. \033[0m\n"
