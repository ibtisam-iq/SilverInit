#!/bin/bash

# SilverInit - Update OS and Get System Information
# -------------------------------------------------
# This script updates the system and displays system information.

# Exit immediately if a command fails
set -e  

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running preflight.sh script to ensure that system meets the requirements ..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }

# Update and install necessary dependencies
echo -e "\n🚀 Updating the system first time and installing all vital dependencies, please be patient ...\n"
sudo apt update -qq && sudo apt install -yq net-tools apt-transport-https ca-certificates curl gpg jq lsb-release python3-pip tree wget gnupg > /dev/null 2>&1

# Prompt user for a hostname (leave empty to keep the current one)
echo -e "\n🔹 Current hostname: $(hostname)\n"
read -p "🔄 Do you want to update the hostname? Enter new name (or press Enter to keep current): " NEW_HOSTNAME < /dev/tty

# Set hostname if provided
if [[ -n "$NEW_HOSTNAME" ]]; then
    echo -e "\n🖥️ Updating hostname to '$NEW_HOSTNAME'..."
    if command -v hostnamectl &>/dev/null; then
        sudo hostnamectl set-hostname "$NEW_HOSTNAME"
        echo -e "\n✅ Hostname updated successfully."
    else
        echo -e "\n⚠️ Warning: 'hostnamectl' not found, skipping hostname update."
    fi
else
    echo -e "\nℹ️ Keeping the existing hostname: $(hostname)"
fi

# Display system information
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

# Compare this snippet from SilverInit/sys-info-and-update.sh:
echo -e "now let's compare this snippet from SilverInit/sys-info-and-update.sh"

#/bin/bash

# SilverInit - Update OS and Get System Information
# -------------------------------------------------
# This script updates the system and displays system information.

# Exit immediately if a command fails
set -e  

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# Colors for better readability
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Section Divider
divider() {
    echo -e "${CYAN}========================================${RESET}"
}

# Preflight Check
echo -e "\n🚀 Running preflight.sh script to ensure system meets requirements..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }

# Update and install necessary dependencies
echo -e "\n🚀 Updating system and installing dependencies, please wait...\n"
sudo apt update -qq && sudo apt install -yq net-tools apt-transport-https ca-certificates curl gpg jq lsb-release python3-pip tree wget gnupg > /dev/null 2>&1

# Prompt user for hostname update
divider
echo -e "🔹 ${YELLOW}Current hostname${RESET}: $(hostname)"
read -p "🔄 Do you want to update the hostname? Enter new name (or press Enter to keep current): " NEW_HOSTNAME < /dev/tty

if [[ -n "$NEW_HOSTNAME" ]]; then
    echo -e "\n🖥️ Updating hostname to '$NEW_HOSTNAME'..."
    if command -v hostnamectl &>/dev/null; then
        sudo hostnamectl set-hostname "$NEW_HOSTNAME"
        echo -e "\n✅ Hostname updated successfully."
    else
        echo -e "\n⚠️ Warning: 'hostnamectl' not found, skipping hostname update."
    fi
else
    echo -e "\nℹ️ Keeping the existing hostname: $(hostname)"
fi

# Get System Information
divider
echo -e "📌 ${CYAN}System Information${RESET}"
divider

echo -e "🔹 Hostname       : $(hostname)"
echo -e "🔹 Private IP     : $(hostname -I | awk '{print $1}')"
echo -e "🔹 Public IP      : $(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 https://ipinfo.io/ip || echo '⚠️ Failed to retrieve IP')"
echo -e "🔹 MAC Address    : $(ip link show | awk '/link\/ether/ {print $2}' | paste -sd ', ')"
echo -e "🔹 Network        : $(ip addr show | awk '/inet / {print $2}' | paste -sd ', ')"
echo -e "🔹 DNS            : $(awk '/nameserver/ {print $2}' /etc/resolv.conf | paste -sd ', ')"
echo -e "🔹 Kernel         : $(uname -r)"
echo -e "🔹 OS             : $(lsb_release -ds)"
echo -e "🔹 CPU            : $(lscpu | grep 'Model name' | awk -F ':' '{print $2}' | xargs)"
echo -e "🔹 Memory         : $(free -h | awk '/Mem/ {print $2}')"
echo -e "🔹 Disk Usage     : $(df -h --total | grep 'total' | awk '{print $3 "/" $2}')"
echo -e "🔹 CPU Load       : $(uptime | awk -F 'load average:' '{print $2}')"
echo -e "🔹 UUID           : $(cat /etc/machine-id)"

divider
echo -e "✅ ${GREEN}The system is now updated and ready!${RESET}"
divider
