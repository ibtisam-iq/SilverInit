#!/bin/bash

# ╔════════════════════════════════════════════════════════╗
# ║      SilverInit - System Update & Information          ║
# ║      (c) 2025 Muhammad Ibtisam Iqbal                   ║
# ║      License: MIT                                      ║
# ╚════════════════════════════════════════════════════════╝
# 
# 📌 Description:
# This script updates the system and provides detailed system information.
# It includes:
#   - ✅ Running a preflight check before execution
#   - ✅ Updating the system (if not skipped)
#   - ✅ Gathering and displaying system information
#   - ✅ Prompting for a hostname change (if not in quiet mode)
#
# 🚀 Usage:
#   sudo bash sys-info-and-update.sh [options]
#
# 📌 Options:
#   -q           : Quiet mode (no prompts)
#   --no-update  : Skip system update
#   -h | --help  : Show this help menu
#
# 📜 License: MIT | 🌐 https://github.com/ibtisam-iq/SilverInit


set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# 🎨 Colors for better visibility
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# -------------------------------
# 🛠️ Configuration
# -------------------------------
LOG_FILE="/var/log/sysinfo.log"
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"
QUIET_MODE=false
SKIP_UPDATE=false

# -------------------------------
# 🏗️ Functions
# -------------------------------

# Print Divider
divider() {
    echo -e "${CYAN}========================================${RESET}"
}

# Log Function (Print & Save to Log File)
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
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
        *) echo -e "${RED}❌ Unknown option: $1${RESET}"; exit 1 ;;
    esac
    shift
done

# -------------------------------
# 🚀 Preflight Check
# -------------------------------
divider
log "🔍 ${YELLOW}Running system preflight checks...${RESET}"
divider

bash <(curl -sL "$REPO_URL/preflight.sh") || { log "❌ Preflight check failed! Exiting..."; exit 1; }

# -------------------------------
# 🔄 System Update (if not skipped)
# -------------------------------
if [[ "$SKIP_UPDATE" == false ]]; then
    divider
    log "🚀 ${YELLOW}Updating system and installing dependencies...${RESET}"
    divider
    sudo apt update -qq && sudo apt install -yq net-tools apt-transport-https ca-certificates curl gpg jq lsb-release python3-pip tree wget gnupg > /dev/null 2>&1
    log "✅ ${GREEN}System update completed successfully.${RESET}"
fi

# -------------------------------
# 🖥️ Hostname Configuration
# -------------------------------
divider
log "🔹 ${YELLOW}Current hostname${RESET}: $(hostname)"
if [[ "$QUIET_MODE" == false ]]; then
    read -p "🔄 Change hostname? Enter new name (or press Enter to keep current): " NEW_HOSTNAME < /dev/tty
    if [[ -n "$NEW_HOSTNAME" ]]; then
        log "\n🖥️ Updating hostname to '$NEW_HOSTNAME'..."
        sudo hostnamectl set-hostname "$NEW_HOSTNAME"
        log "✅ ${GREEN}Hostname updated successfully.${RESET}"
    else
        log "\nℹ️ Keeping the existing hostname: $(hostname)"
    fi
fi

# -------------------------------
# 📊 System Information
# -------------------------------
divider
log "📌 ${CYAN}System Information${RESET}"
divider

log "🔹 Hostname       : $(hostname)"
log "🔹 Private IP     : $(hostname -I | awk '{print $1}')"
log "🔹 Public IP      : $(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 https://ipinfo.io/ip || echo '⚠️ Failed to retrieve IP')"
log "🔹 MAC Address    : $(ip link show | awk '/link\/ether/ {print $2}' | paste -sd ', ')"
log "🔹 Network        : $(ip addr show | awk '/inet / {print $2}' | paste -sd ', ')"
log "🔹 DNS            : $(awk '/nameserver/ {print $2}' /etc/resolv.conf | paste -sd ', ')"
log "🔹 Kernel         : $(uname -r)"
log "🔹 OS             : $(lsb_release -ds)"
log "🔹 CPU            : $(lscpu | grep 'Model name' | awk -F ':' '{print $2}' | xargs)"
log "🔹 Memory         : $(free -h | awk '/Mem/ {print $2}')"
log "🔹 Disk Usage     : $(df -h --total | grep 'total' | awk '{print $3 "/" $2}')"
log "🔹 CPU Load       : $(uptime | awk -F 'load average:' '{print $2}')"
log "🔹 UUID           : $(cat /etc/machine-id)"

divider
log "✅ ${GREEN}The system is now updated and ready!${RESET}"
divider
