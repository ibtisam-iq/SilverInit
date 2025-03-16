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
# 7. Helm installation

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
    "aws-cli-conf.sh"
    "terraform-setup.sh"
    "ansible-setup.sh"
    "kubectl-and-eksctl.sh"
)

for script in "${SCRIPTS[@]}"; do
    echo -e "\n🚀 Running $script..."
    bash <(curl -fsSL "$REPO_URL/$script") || { echo -e "\n❌ Failed to execute $script. Exiting...\n"; exit 1; }
done

# Install Helm securely
echo -e "\n🚀 Installing Helm..."
if curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash; then
    echo -e "\n✅ Helm installation completed successfully."
else
    echo -e "\n❌ Helm installation script failed. Debugging..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o get-helm.sh || { echo "❌ Failed to download Helm installation script. Exiting..."; exit 1; }
    chmod +x get-helm.sh
    sudo ./get-helm.sh > /dev/null 2>&1 || { echo "❌ Failed to install Helm. Exiting..."; exit 1; }
fi
helm version || echo "⚠️ Helm installed, but version check failed."

echo -e "\n✅ All scripts executed successfully.\n"

echo -e "🎉 Jumpbox setup completed. You can now manage AWS resources using this server.\n"