#!/bin/bash

# SilverInit - Preflight Checks
# -------------------------------------------------
# This script performs preflight checks to ensure the system meets the requirements for running other scripts.

# Preflight checks include:
# - Running as root
# - Checking for required commands
# - Verifying internet connectivity
# - Validating the OS and architecture

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

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

#!/bin/bash

# ╔══════════════════════════════════════════════════╗
# ║          SilverInit - Preflight Checks           ║
# ║          (c) 2025 Muhammad Ibtisam Iqbal         ║
# ║          License: MIT                            ║
# ╚══════════════════════════════════════════════════╝
# 
# 📌 Description:
# This script ensures that the system meets the requirements for running 
# other SilverInit scripts. It performs:
#   - ✅ Root user verification
#   - ✅ Checking required dependencies (curl, bash)
#   - ✅ Internet connectivity check
#   - ✅ OS compatibility check (Ubuntu/Linux Mint)
#   - ✅ Architecture validation (x86_64 / amd64)
#
# 🚀 Usage:
#   curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/preflight.sh | sudo bash
#
# 📜 License: MIT | 🌐 https://github.com/ibtisam-iq/SilverInit
#

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# 🎨 Colors for better visibility
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

echo -e "\n${YELLOW}========================================${RESET}"
echo -e "🚀 ${GREEN}SilverInit - System Preflight Checks${RESET}"
echo -e "${YELLOW}========================================${RESET}\n"

# Ensure the script is running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ This script must be run as root. Use: sudo bash $(basename "$0")${RESET}\n"
    exit 1
fi
echo -e "✅ ${GREEN}Running as root.${RESET}\n"

# Function to check and install a missing package
check_and_install() {
    if ! command -v "$1" &>/dev/null; then
        echo -e "⚠️  ${YELLOW}Installing missing dependency: $1...${RESET}"
        sudo apt update -qq && sudo apt install -yq "$1" > /dev/null 2>&1
        echo -e "✅ ${GREEN}$1 installed successfully.${RESET}\n"
    else
        echo -e "✅ ${GREEN}$1 is already installed.${RESET}\n"
    fi
}

# Ensure required dependencies are installed
for cmd in curl bash; do
    check_and_install "$cmd"
done

# Check internet connectivity
if ! ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
    echo -e "${RED}❌ No internet connection. Please check your network and retry.${RESET}\n"
    exit 1
fi
echo -e "✅ ${GREEN}Internet connection verified.${RESET}\n"

# Verify OS compatibility
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|linuxmint) echo -e "✅ ${GREEN}Detected OS: $PRETTY_NAME${RESET}\n" ;;
        *) 
            echo -e "${RED}❌ Unsupported OS: $ID. This script supports only Ubuntu & Linux Mint.${RESET}\n"
            exit 1
            ;;
    esac
else
    echo -e "${RED}❌ Unable to determine OS type. Exiting...${RESET}\n"
    exit 1
fi

# Ensure 64-bit architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "amd64" ]]; then
    echo -e "${RED}❌ Unsupported architecture: $ARCH. This script supports only x86_64 (amd64).${RESET}\n"
    exit 1
fi
echo -e "✅ ${GREEN}Architecture supported: $ARCH${RESET}\n"

echo -e "🚀 ${GREEN}Preflight checks completed successfully! Your system is ready.${RESET}\n"