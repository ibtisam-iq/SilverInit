#!/bin/bash
# SilverInit - Jumpbox Setup
# -------------------------------------------------
# This script automates the setup of a jumpbox server for managing AWS resources.
# It executes a sequence of scripts to configure the OS, install required tools,
# and set up AWS CLI, Terraform, Ansible, and Kubernetes tools.
# It runs on a fresh Ubuntu server instance.

# The following scripts are executed in sequence:
# 1. sys-info-and-update.sh
# 2. aws-cli-conf.sh
# 3. terraform-setup.sh
# 4. ansible-setup.sh
# 5. kubectl-and-eksctl.sh
# 6. Helm installation


# Ensure script is run as root
# -------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo -e "\n❌ This script must be run as root. Run the command with:\n"
    echo "   sudo bash <(curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/Jumpbox.sh)"
    exit 1
fi

# -------------------------------------------------

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# Define the repository URL
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure required commands are available
for cmd in curl bash; do
    if ! command_exists "$cmd"; then
        echo -e "\n❌ Missing dependency: $cmd. Please install it and retry.\n"
        exit 1
    fi
done

# Check internet connectivity
if ! curl -s --head --fail https://www.google.com > /dev/null; then
    echo -e "\n❌ No internet connection. Please check your network and retry.\n"
    exit 1
fi

# Execute required scripts in sequence
SCRIPTS=(
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
if curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; then
    echo -e "\n✅ Helm installation completed successfully."
    helm version || echo "⚠️ Helm installed, but version check failed."
else
    echo -e "\n❌ Failed to install Helm. Exiting..."
    exit 1
fi

echo -e "\n✅ All scripts executed successfully.\n"
echo -e "🎉 Jumpbox setup completed. You can now manage AWS resources using this server.\n"