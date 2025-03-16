#!/bin/bash

# ███████╗██╗██╗    ██╗   ██╗███████╗██████╗ ██╗███╗   ██╗██╗████████╗
# ██╔════╝██║██║    ██║   ██║██╔════╝██╔══██╗██║████╗  ██║██║╚══██╔══╝
# ███████╗██║██║    ██║   ██║█████╗  ██████╔╝██║██╔██╗ ██║██║   ██║   
# ╚════██║██║██║    ╚██╗ ██╔╝██╔══╝  ██╔══██╗██║██║╚██╗██║██║   ██║   
# ███████║██║███████╗╚████╔╝ ███████╗██║  ██║██║██║ ╚████║██║   ██║   
# ╚══════╝╚═╝╚══════╝ ╚═══╝  ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

# ╔══════════════════════════════════════════════════════════════════╗
# ║    SilverInit - Kubernetes Node Setup                            ║
# ║    (c) 2025 Muhammad Ibtisam Iqbal                               ║
# ║    License: MIT | 🌐 https://github.com/ibtisam-iq/SilverInit    ║
# ╚══════════════════════════════════════════════════════════════════╝

# 🚀 Description:
# This script sets up a node for Kubernetes by:
# - Disabling swap
# - Installing required dependencies
# - Configuring sysctl settings for networking
# - Adding Kubernetes APT repository & installing kubeadm, kubelet, kubectl
# - Setting up containerd as the runtime

# ==================================================
# 🛠️ Setup: Run as root (or with sudo privileges)
# Usage:
#   curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/k8s-node-setup.sh | sudo bash
# ==================================================

set -e  # Exit on error
set -o pipefail  # Fail if any command in a pipeline fails
trap 'echo -e "\n\033[1;31m❌ Error occurred at line $LINENO. Exiting...\033[0m\n" && exit 1' ERR

# Color Variables
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # No Color

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "${BLUE}\n🚀 Running sys-info-and-update.sh...${NC}"
bash <(curl -sL "$REPO_URL/sys-info-and-update.sh") || { echo -e "${RED}\n❌ Failed to execute sys-info-and-update.sh. Exiting...${NC}"; exit 1; }

echo -e "${GREEN}\n✅ System meets the requirements to set up a Kubernetes cluster.${NC}"

echo -e "${YELLOW}\n🔧 Disabling swap...${NC}"
sudo swapoff -a
sudo sed -i '/\s\+swap\s\+/d' /etc/fstab

echo -e "${BLUE}\n📦 Adding Kubernetes APT repository...${NC}"
sudo mkdir -p -m 755 /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]]; then
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt update -qq

echo -e "${YELLOW}\n📥 Installing Kubernetes components...${NC}"
sudo apt-get install -yq kubelet kubeadm kubectl > /dev/null 2>&1
sudo apt-mark hold kubelet kubeadm kubectl

echo -e "${GREEN}\n✅ Kubernetes components installed successfully!${NC}"

echo -e "${YELLOW}\n🛠️ Loading required kernel modules...${NC}"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo -e "${BLUE}\n⚙️ Applying sysctl settings...${NC}"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system > /dev/null

echo -e "${GREEN}\n✅ Kernel modules loaded, and sysctl settings applied!${NC}"

echo -e "${BLUE}\n🚀 Running containerd-setup.sh script...${NC}"
bash <(curl -sL "$REPO_URL/containerd-setup.sh") || { echo -e "${RED}\n❌ Failed to execute containerd-setup.sh. Exiting...${NC}"; exit 1; }

echo -e "${GREEN}\n✅ All scripts executed successfully.${NC}"
echo -e "${YELLOW}\n✅ This node is ready to join the Kubernetes cluster.${NC}"
echo -e "${GREEN}\n🎉 Happy Kuberneting! 🚀${NC}"
