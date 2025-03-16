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


# Define a function for formatting
print_line() {
    echo -e "========================================"
}
print_title() {
    echo -e "📌 \033[1;36m$1\033[0m"
}

# Display system information
clear
print_line
print_title "System Information"
print_line

# Hostname & IP Details
echo -e "🔹 \033[1;32mHostname       \033[0m: $(hostname)"
echo -e "🔹 \033[1;32mPrivate IP     \033[0m: $(hostname -I | awk '{print $1}')"
echo -e "🔹 \033[1;32mPublic IP      \033[0m: $(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 https://ipinfo.io/ip || echo '⚠️ Failed to retrieve IP')"

# MAC Address & Network Info
echo -e "🔹 \033[1;32mMAC Address    \033[0m: $(ip link show | awk '/link\/ether/ {print $2}' | paste -sd ', ' -)"
echo -e "🔹 \033[1;32mNetwork        \033[0m: $(ip addr show | awk '/inet / {print $2}' | paste -sd ', ' -)"
echo -e "🔹 \033[1;32mDNS            \033[0m: $(awk '/nameserver/ {print $2}' /etc/resolv.conf | paste -sd ', ' -)"

# System Details
echo -e "🔹 \033[1;34mKernel         \033[0m: $(uname -r)"
echo -e "🔹 \033[1;34mOS             \033[0m: $(lsb_release -ds)"
echo -e "🔹 \033[1;34mCPU            \033[0m: $(lscpu | grep 'Model name' | awk -F ':' '{print $2}' | xargs)"
echo -e "🔹 \033[1;34mMemory         \033[0m: $(free -h | awk '/Mem/ {print $2}')"

# Disk Usage & Load
disk_usage=$(df -h --total | awk '/total/ {print $3 "/" $2}')
cpu_load=$(uptime | awk -F 'load average:' '{print $2}' | xargs)

echo -e "🔹 \033[1;35mDisk Usage     \033[0m: $disk_usage"
echo -e "🔹 \033[1;35mCPU Load       \033[0m: $cpu_load"

print_line
echo -e '✅ \033[1;32mThe system is now updated and ready!\033[0m'
print_line

