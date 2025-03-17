#!/bin/bash

# ╔══════════════════════════════════════════════════╗
# ║          SilverInit - Jumpbox Setup              ║
# ║          (c) 2025 Muhammad Ibtisam Iqbal         ║
# ║          License: MIT                            ║
# ╚══════════════════════════════════════════════════╝
# 
# 📌 Description:
# This script automates the setup of a jumpbox server for managing AWS resources.
# It executes a sequence of scripts to configure the OS, install required tools,
# and set up AWS CLI, Terraform, Ansible, and Kubernetes tools.
# It runs on a fresh Ubuntu server instance.
# 
# 🚀 Scripts Executed in Sequence:
#   1️⃣ preflight.sh - System checks and prerequisites
#   2️⃣ sys-info-and-update.sh - Updates and system info
#   3️⃣ terraform-setup.sh - Installs Terraform
#   4️⃣ ansible-setup.sh - Installs Ansible
#   5️⃣ kubectl-and-eksctl.sh - Installs Kubernetes CLI tools
#   6️⃣ helm-setup.sh - Installs Helm
#   7️⃣ aws-cli-conf.sh - Configures AWS CLI
# 
# 🔧 Usage:
#   curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/Jumpbox.sh | sudo bash
# 
# 📜 License: MIT | 🌐 https://github.com/ibtisam-iq/SilverInit

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n\033[1;31m❌ Error occurred at line $LINENO. Exiting...\033[0m\n" && exit 1' ERR

# Define the repository URL
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# List of scripts to execute
SCRIPTS=(
    "preflight.sh"
    "sys-info-and-update.sh"
    "terraform-setup.sh"
    "ansible-setup.sh"
    "kubectl-and-eksctl.sh"
    "helm-setup.sh"
    # "aws-cli-conf.sh"
)

# ==================================================
# 🚀 Executing Scripts
# ==================================================
for script in "${SCRIPTS[@]}"; do
    echo -e "\n\033[1;34m🚀 Running $script script...\033[0m"
    bash <(curl -fsSL "$REPO_URL/$script") || { echo -e "\n\033[1;31m❌ Failed to execute $script. Exiting...\033[0m\n"; exit 1; }
    echo -e "\033[1;32m✅ Successfully executed $script.\033[0m\n"

done

# ==================================================
# 🎉 Completion Message
# ==================================================
echo -e "\n\033[1;32m✅ All scripts executed successfully.\033[0m\n"
echo -e "\033[1;36m🎉 Jumpbox setup completed. You can now manage AWS resources using this server.\033[0m\n"
echo -e "\033[1;32m✅ Thanks for using SilverInit!\033[0m\n"

# ==================================================
# 🎉 Setup Complete! Thank You! 🙌
# ==================================================
echo -e "\n\033[1;33m✨  Thank you for choosing SilverInit - Muhammad Ibtisam 🚀\033[0m\n"
echo -e "\033[1;32m💡 Automation is not about replacing humans; it's about freeing them to be more human—to create, innovate, and lead. \033[0m\n"