#!/bin/bash

set -euo pipefail
trap 'echo -e "\n\033[1;31m❌ Error at line $LINENO. Exiting...\033[0m"; exit 1' ERR

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# Adding CNI plugins directory
echo -e "\n\033[1;34m✅ Ensuring CNI plugins directory exists...\033[0m"
sudo mkdir -p /opt/cni/bin

echo -e "\n\033[1;34m✅ Fetching latest CNI plugin version...\033[0m"
CNI_VERSION=$(curl -s https://api.github.com/repos/containernetworking/plugins/releases/latest | jq -r '.tag_name')
CNI_TARBALL="cni-plugins-linux-amd64-${CNI_VERSION}.tgz"

if [[ ! -f "$CNI_TARBALL" ]]; then
    echo -e "\n\033[1;34m✅ Downloading CNI plugins...\033[0m"
    wget -q "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/${CNI_TARBALL}"
fi

if [[ -f "$CNI_TARBALL" ]]; then
    echo -e "\n\033[1;34m✅ Extracting CNI plugins...\033[0m"
    sudo tar -C /opt/cni/bin -xzvf "$CNI_TARBALL" > /dev/null
    rm -f "$CNI_TARBALL"
else
    echo -e "\n\033[1;31m❌ Failed to download CNI plugins. Exiting...\033[0m"
    exit 1
fi

# Validate CNI plugin installation
echo -e "\n\033[1;34m✅ Validating CNI plugin installation...\033[0m"
sudo ls /opt/cni/bin/ || { echo -e "\n\033[1;31m❌ CNI plugins not found. Exiting...\033[0m"; exit 1; }

# ==================================================
# Restarting Required Services
# ==================================================

# Ensure required services are running
echo -e "\n\033[1;33m🔍 Ensuring necessary services are running...\033[0m"
sudo systemctl start containerd kubelet || true
sudo systemctl enable containerd kubelet --now || true
for service in containerd kubelet; do
    echo -n "$service: "
    systemctl is-active "$service"
done
echo -e "\n"
echo -e "\n\033[1;32m kubelet is activating, because it's waiting for the API server (which kubeadm init starts)..\033[0m"
echo -e "\n"
# Since kubeadm init is not run, and kubelet needs a valid configuration to work, it keeps crashing and restarting.

# ubuntu@ip-172-31-17-2:~$ systemctl is-active "kubelet"
# activating
