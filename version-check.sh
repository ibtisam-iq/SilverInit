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

log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "  \e[1;36m🔹 Ansible:         \e[0m $(ansible --version | head -n1 | awk '{print $NF}' | tr -d ']')"
log "  \e[1;36m🔹 AWS CLI:         \e[0m $(aws --version | awk '{print $1}' | cut -d'/' -f2)"
log "  \e[1;36m🔹 Docker:          \e[0m $(docker --version | awk '{print $3}' | sed 's/,//')"
log "  \e[1;36m🔹 Containerd:      \e[0m $(containerd --version | awk '{print $3}')"
log "  \e[1;36m🔹 Runc:            \e[0m $(runc --version | awk '{print $3}')"
log "  \e[1;36m🔹 Git:             \e[0m $(git --version | awk '{print $3}')"
log "  \e[1;36m🔹 Helm:            \e[0m $(helm version --template '{{.Version}}')"
log "  \e[1;36m🔹 Jenkins:         \e[0m $(jenkins --version 2>/dev/null || echo 'Not Installed')"
log "  \e[1;36m🔹 kubectl:         \e[0m $(kubectl version --client --output=yaml | grep gitVersion | awk '{print $2}')"
log "  \e[1;36m🔹 eksctl:          \e[0m $(eksctl version)"
log "  \e[1;36m🔹 Terraform:       \e[0m $(terraform --version | head -n1 | awk '{print $2}')"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log "\n\e[1;32m✅ Version check completed successfully.\e[0m\n"
