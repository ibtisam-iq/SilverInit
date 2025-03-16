#!/bin/bash

# SilverInit - Preflight Checks
# -------------------------------------------------
# This script performs preflight checks to ensure the system meets the requirements for running other scripts.

# Preflight checks include:
# - Running as root
# - Checking for required commands
# - Verifying internet connectivity
# - Validating the OS and architecture

# Ensure the script is running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "\n❌ This script must be run as root. Please use: sudo bash $(basename "$0")\n"
    exit 1
fi
echo -e "\n✅ The script is running as root.\n"

# Function to install a missing package
install_package() {
    echo -e "\n⚠️  Installing missing dependency: $1...\n"
    sudo apt update -y -qq && sudo apt install -yq "$1" > /dev/null 2>&1
    echo -e "✅ $1 installed successfully.\n"
}

# Ensure required commands are available
for cmd in curl bash; do
    if ! command -v "$cmd" &>/dev/null; then
        install_package "$cmd"
    fi
done

echo -e "\n✅ All required dependencies are installed.\n"

# Check internet connectivity
if ! curl -s --head --fail https://www.google.com > /dev/null; then
    echo -e "\n❌ No internet connection. Please check your network and retry.\n"
    exit 1
fi
echo -e "\n✅ Internet connection verified.\n"

# Safety settings
set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# Ensure the script is running on Ubuntu or Linux Mint
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "linuxmint" ]]; then
        echo -e "\n❌ Unsupported OS: $ID - This script is only for Ubuntu/Linux Mint. Exiting...\n"
        exit 1
    fi
    echo -e "\n✅ Detected OS: $ID\n"
else
    echo -e "\n❌ Unable to determine OS type. Exiting...\n"
    exit 1
fi

# Ensure 64-bit architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "amd64" ]]; then # FIX: Use `&&` instead of `||`
    echo -e "\n❌ Unsupported architecture: $ARCH. This script supports only x86_64 (amd64). Exiting...\n"
    exit 1
fi
echo -e "\n✅ Architecture supported: $ARCH\n"