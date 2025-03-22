#!/bin/bash

# ╔════════════════════════════════════════════════════════╗
# ║               SilverInit - Version Check               ║
# ║               (c) 2025 Muhammad Ibtisam Iqbal          ║
# ║               License: MIT                             ║
# ╚════════════════════════════════════════════════════════╝
# 
# This script checks and displays the versions of essential DevOps tools.

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected
trap 'echo -e "\n\e[1;31m❌ Error occurred at line $LINENO. Exiting...\e[0m\n" && exit 1' ERR  # Handle script failures

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# Log Function (Print & Save to Log File)
log() {
    echo -e "$1"
}

# -------------------------------
# 🚀 Preflight Check
# -------------------------------
log "\n\e[1;34m🚀 Running preflight check...\e[0m\n"
bash <(curl -sL "$REPO_URL/preflight.sh") || { log "\e[1;31m❌ Preflight check failed! Exiting...\e[0m\n"; exit 1; }
log "\e[1;32m✅ Preflight check passed!\e[0m\n"

# -------------------------------
# 📌 Installed Tools Version
# -------------------------------

echo -e "\n\e[1;33m📌 Installed Tools and Versions:\e[0m\n"

log "\e[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
log "  \e[1;36m🔹 Ansible:        \e[0m \e[1;32m$(ansible --version | head -n1 | awk '{print $NF}' | tr -d ']')\e[0m"
log "  \e[1;36m🔹 AWS CLI:        \e[0m \e[1;32m$(aws --version | awk '{print $1}' | cut -d'/' -f2)\e[0m"
log "  \e[1;36m🔹 Docker:         \e[0m \e[1;32m$(docker --version | awk '{print $3}' | sed 's/,//')\e[0m"
log "  \e[1;36m🔹 Containerd:     \e[0m \e[1;32m$(containerd --version | awk '{print $3}')\e[0m"
log "  \e[1;36m🔹 Runc:           \e[0m \e[1;32m$(runc --version | awk '{print $3}')\e[0m"
log "  \e[1;36m🔹 Git:            \e[0m \e[1;32m$(git --version | awk '{print $3}')\e[0m"
log "  \e[1;36m🔹 Helm:           \e[0m \e[1;32m$(helm version --template '{{.Version}}')\e[0m"
log "  \e[1;36m🔹 Jenkins:        \e[0m \e[1;32m$(jenkins --version 2>/dev/null || echo 'Not Installed')\e[0m"
log "  \e[1;36m🔹 kubectl:        \e[0m \e[1;32m$(kubectl version --client --output=yaml | grep gitVersion | awk '{print $2}')\e[0m"
log "  \e[1;36m🔹 eksctl:         \e[0m \e[1;32m$(eksctl version)\e[0m"
log "  \e[1;36m🔹 Terraform:      \e[0m \e[1;32m$(terraform --version | head -n1 | awk '{print $2}')\e[0m"
log "\e[1;35m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"

log "\n\e[1;32m✅ Version check completed successfully.\e[0m\n"
log "\n\e[1;34m🚀 Happy Coding! 🚀\e[0m\n"
