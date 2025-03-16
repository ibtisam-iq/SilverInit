#!/bin/bash
# SilverInit - Jumpbox Setup
# -------------------------------------------------
# This script automates the setup of a jumpbox server for managing AWS resources.
# It executes a sequence of scripts to configure the OS, install required tools,
# and set up AWS CLI, Terraform, Ansible, and Kubernetes tools.
# It runs on a fresh Ubuntu server instance.

# The following scripts are executed in sequence:
# 1. preflight.sh
# 2. sys-info-and-update.sh
# 3. aws-cli-conf.sh
# 4. terraform-setup.sh
# 5. ansible-setup.sh
# 6. kubectl-and-eksctl.sh
# 7. helm-setup.sh

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# Define the repository URL
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# Execute required scripts in sequence
SCRIPTS=(
    "preflight.sh"
    "sys-info-and-update.sh"
    "terraform-setup.sh"
    "ansible-setup.sh"
    "kubectl-and-eksctl.sh"
    "helm-setup.sh"
    # "aws-cli-conf.sh"
)

for script in "${SCRIPTS[@]}"; do
    echo -e "\n🚀 Running $script script..."
    bash <(curl -fsSL "$REPO_URL/$script") || { echo -e "\n❌ Failed to execute $script script. Exiting...\n"; exit 1; }
done

echo -e "\n✅ All scripts executed successfully.\n"

echo -e "🎉 Jumpbox setup completed. You can now manage AWS resources using this server.\n"