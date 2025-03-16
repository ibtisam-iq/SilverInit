#!/bin/bash

# SilverInit - Update OS and Get System Information
# -------------------------------------------------
# This script updates the system and displays system information.

# Exit immediately if a command fails
set -e  

# Ensure the script is running on Ubuntu or Linux Mint
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]; then
        echo -e "\n✅ Detected supported OS: $NAME ($ID)"
    else
        echo -e "\n❌ This script is only for Ubuntu or Linux Mint. Exiting...\n"
        exit 1
    fi
else
    echo -e "\n❌ Unable to determine OS type. Exiting...\n"
    exit 1
fi

# Ensure the system is running on a 64-bit architecture (x86_64 or amd64)
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then
    echo -e "\n✅ Architecture supported: $ARCH"
else
    echo -e "\n❌ Unsupported architecture: $ARCH. This script only supports x86_64 (amd64). Exiting...\n"
    exit 1
fi

# Update and install necessary dependencies
echo -e "\n🚀 Updating system and installing dependencies...\n"
sudo apt update -qq && sudo apt install -yq net-tools apt-transport-https ca-certificates curl gpg jq lsb-release python3-pip tree wget gnupg > /dev/null 2>&1

# Prompt user for a hostname (leave empty to keep the current one)
echo -e "\n🔹 Current hostname: $(hostname)\n"
read -p "🔄 Do you want to update the hostname? Enter new name (or press Enter to keep current): " NEW_HOSTNAME < /dev/tty

# Set hostname if provided
if [[ -n "$NEW_HOSTNAME" ]]; then
    echo -e "\n🖥️ Updating hostname to '$NEW_HOSTNAME'..."
    if command -v hostnamectl &>/dev/null; then
        sudo hostnamectl set-hostname "$NEW_HOSTNAME"
        echo "✅ Hostname updated successfully."
    else
        echo "⚠️ Warning: 'hostnamectl' not found, skipping hostname update."
    fi
else
    echo "ℹ️ Keeping the existing hostname."
fi

# Display system information before Kubernetes setup
echo -e "\n====================================="
echo -e "📌 System Information"
echo -e "=====================================\n"

echo -e "🔹 Hostname: $(hostname)"
echo -e "🔹 Private IP: $(hostname -I | awk '{print $1}')"
echo -e "🔹 Public IP: $(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 https://ipinfo.io/ip || echo '⚠️ Failed to retrieve IP')"
echo -e "🔹 MAC addresses:\n$(ip link show | awk '/link\/ether/ {print "  - MAC Address:", $2}')"
echo -e "🔹 Network information:\n$(ip addr show | awk '/inet / {print "  - Network:", $2}')"
echo -e "🔹 DNS information: $(awk '/nameserver/ {print $2}' /etc/resolv.conf)"
echo -e "🔹 Kernel version: $(uname -r)"
echo -e "🔹 OS version: $(lsb_release -ds)"
echo -e "🔹 CPU: $(lscpu | grep 'Model name' | awk -F ':' '{print $2}')"
echo -e "🔹 Memory: $(free -h | awk '/Mem/ {print $2}')"
echo -e "🔹 Disk usage:\n$(df -h --total | grep 'total' | awk '{print "  - Used:", $3, "/", $2}')"
echo -e "🔹 CPU Load: $(uptime | awk -F 'load average:' '{print $2}')\n"

echo -e "✅ The system is now updated and ready now!\n"