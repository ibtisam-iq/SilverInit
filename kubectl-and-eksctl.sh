#!/bin/bash

# SilverInit - Kubectl and Eksctl Installation Script
# -------------------------------------------------
# This script installs kubectl and eksctl on Linux.


set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Handle script failures
trap 'echo -e "\n\033[1;31m❌ Error occurred at line $LINENO. Exiting...\033[0m\n" && exit 1' ERR

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running preflight.sh script to ensure that system meets the requirements to install kubectl and eksctl..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }
echo -e "\n✅ System meets the requirements to install kubectl and eksctl."


# Install Kubectl
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
# echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# rm -rf kubectl kubectl.sha256

# Install eksctl
# ARCH=amd64
# PLATFORM=$(uname -s)_$ARCH
# curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
# curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
# tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
# sudo mv /tmp/eksctl /usr/local/bin
# rm -rf eksctl_$PLATFORM.tar.gz

# Install kubectl
echo -e "\n🚀 Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /dev/null 2>&1
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo -e "\n✅ kubectl installed successfully. Version: $(kubectl version --client --output=yaml | grep gitVersion | awk '{print $2}')"

# Install eksctl
echo -e "\n🚀 Installing eksctl..."
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" -o eksctl.tar.gz
tar -xzf eksctl.tar.gz
sudo mv eksctl /usr/local/bin/
rm -f eksctl.tar.gz
echo -e "\n✅ eksctl installed successfully. Version: $(eksctl version)\n" 