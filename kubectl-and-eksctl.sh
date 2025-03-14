#!/bin/bash

# SilverInit - Kubectl and Eksctl Installation Script
# -------------------------------------------------
# This script installs kubectl and eksctl on Linux.


# Exit immediately if a command fails
set -e  

# Ensure the system is running on a 64-bit architecture (x86_64 or amd64)
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then
    echo -e "\n✅ Architecture supported: $ARCH"
else
    echo -e "\n❌ Unsupported architecture: $ARCH. This script only supports x86_64 (amd64). Exiting...\n"
    exit 1
fi


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
echo -e "\n🚀 Installing kubectl...\n"
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo -e "✅ kubectl installed successfully. Version:\n$(kubectl version --client --output=yaml | grep gitVersion | awk '{print $2}')"

# Install eksctl
echo -e "\n🚀 Installing eksctl...\n"
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" -o eksctl.tar.gz
tar -xzf eksctl.tar.gz
sudo mv eksctl /usr/local/bin/
rm -f eksctl.tar.gz
echo -e "✅ eksctl installed successfully. Version:\n$(eksctl version)"