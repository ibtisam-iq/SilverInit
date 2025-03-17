#!/bin/bash

# SilverInit - Helm Setup
# -------------------------------------------------
# This script installs Helm on Ubuntu or its derivatives.

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Handle script failures
trap 'echo -e "\n\033[1;31m❌ Error occurred at line $LINENO. Exiting...\033[0m\n" && exit 1' ERR

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running preflight.sh script to ensure that system meets the requirements to install Helm..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }
echo -e "\n✅ System meets the requirements to install Helm."

# Check if Helm is already installed
if command -v helm &> /dev/null; then
    echo -e "\n✅ Helm is already installed. Version: $(helm version --template '{{.Version}}')\n"
    exit 0
fi

# Install Helm securely
echo -e "\n🚀 Installing Helm...\n"
if curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash; then
    echo -e "\n✅ Helm installation completed successfully."
else
    echo -e "\n❌ Helm installation script failed. Debugging..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o get-helm.sh || { echo "❌ Failed to download Helm installation script. Exiting..."; exit 1; }
    chmod +x get-helm.sh
    sudo ./get-helm.sh > /dev/null 2>&1 || { echo "❌ Failed to install Helm. Exiting..."; exit 1; }
fi
echo -e "\n🔹 Helm Version: $(helm version --template '{{.Version}}')"
