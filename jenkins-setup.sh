#!/bin/bash

# -------------------------------------------------
# SilverInit - Jenkins Server Setup
# -------------------------------------------------
# 📌 Description: This script installs Jenkins on Ubuntu or Linux Mint.
# 📌 Usage      : sudo bash jenkins-setup.sh [options]
# 📌 Options    :
#   -q           : Quiet mode (no prompts)
#   --no-update  : Skip system update
#   -h | --help  : Show this help menu
#
# 📌 Author     : Muhammad Ibtisam Iqbal
# 📌 Version    : 1.0.0
# 📌 License    : MIT
# -------------------------------------------------

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

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
    echo -e "${CYAN}========================================${RESET}\n"
}

# Log Function (Print & Save to Log File)
log() {
    echo -e "$1"
}

# Show Help Menu
show_help() {
    echo -e "${CYAN}Usage: sudo bash $0 [options]${RESET}\n"
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

# Preflight Check
divider
log "🚀 Running preflight.sh script to ensure system requirements are met..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { log "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }
log "✅ System meets the requirements to install Jenkins."

divider

# Check if Jenkins is already installed
if command -v jenkins &> /dev/null; then
    log "\n✅ Jenkins is already installed."
    log "\n📌 Installed Jenkins Version: $(jenkins --version)"
    exit 0
fi

divider

# AWS Security Group Warning
log "⚠️  If running on an AWS EC2 instance, ensure port 8080 is open in the security group."

if [[ "$QUIET_MODE" == false ]]; then
    while true; do
        read -r -p "Have you opened port 8080 in your AWS Security Group? (yes/no): " port_check < /dev/tty
        port_check=$(echo "$port_check" | tr '[:upper:]' '[:lower:]')
        if [[ "$port_check" == "yes" ]]; then
            log "\n✅ Port 8080 is open. Proceeding..."
            break
        elif [[ "$port_check" == "no" ]]; then
            read -r -p "🔄 Press Enter after opening port 8080..."
        else
            log "❌ Invalid input! Please enter **yes** or **no**."
        fi
    done
fi

divider

# Update system and install required dependencies
if [[ "$SKIP_UPDATE" == false ]]; then
    log "🚀 Updating package list and checking required dependencies..."
    sudo apt update -qq
fi

divider

# Check if Java is installed
if java -version &>/dev/null; then
    log "✅ Java is already installed."
else
    log "🔹 Installing missing dependency: OpenJDK 17..."
    sudo apt-get install -yq openjdk-17-jdk-headless > /dev/null 2>&1
fi

divider

# Install Jenkins
log "🚀 Installing Jenkins... it may take a few minutes."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key > /dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -qq > /dev/null 2>&1
sudo apt install jenkins -y > /dev/null 2>&1

divider

# Enable & Start Jenkins
log "🔓 Enabling and starting Jenkins..."
sudo systemctl enable jenkins > /dev/null 2>&1
sudo systemctl restart jenkins > /dev/null 2>&1
sleep 10

divider

# Check Jenkins Status
if systemctl is-active --quiet jenkins; then
    log "✅ Jenkins is running."
else
    log "❌ Jenkins is NOT running. Starting Jenkins..."
    sudo systemctl start jenkins
fi

divider

# Display Jenkins Version
log "📌 Installed Jenkins Version: $(jenkins --version)"

divider

# Get the local machine's primary IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Get the public IP (if accessible)
PUBLIC_IP=$(curl -s ifconfig.me || echo "Not Available")

log "🔗 Access Jenkins server using one of the following URLs:"
log " - Local Network:  http://$LOCAL_IP:8080"
log " - Public Network: http://$PUBLIC_IP:8080"

divider

# Display Jenkins Initial Admin Password
log "🔑 Use this password to unlock Jenkins: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"

divider


# ==================================================
# 🎉 Setup Complete! Thank You! 🙌
# ==================================================
echo -e "\n\033[1;33m✨  Thank you for choosing SilverInit - Muhammad Ibtisam 🚀\033[0m\n"
echo -e "\033[1;32m💡 Automation is not about replacing humans; it's about freeing them to be more human—to create, innovate, and lead. \033[0m\n"
