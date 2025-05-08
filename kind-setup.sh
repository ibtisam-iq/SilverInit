#!/bin/bash

# SilverInit - kind Installation Script
# -------------------------------------------------
# This script installs kind on Linux.


set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Handle script failures
trap 'echo -e "\n\033[1;31m❌ Error occurred at line $LINENO. Exiting...\033[0m\n" && exit 1' ERR

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running preflight.sh script to ensure that system meets the requirements to install kind binary..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }
echo -e "\n✅ System meets the requirements to install kind binary."

# Install kind
echo -e "\n🚀 Installing kind..."
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
echo -e "\n✅ kind installed successfully. Version: $(kind version)"