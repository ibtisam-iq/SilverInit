#!/bin/bash

# 📌 Description:
# This script automates the initialization of the first Kubernetes control plane node.
# It assumes that the node is already running and has the necessary dependencies installed.
# The script will configure the node as a Kubernetes control plane node and start the necessary services.

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# 🔧 System Configuration
echo -e "\n\033[1;33m🔧 Disabling swap...\033[0m"
sudo swapoff -a
if grep -q 'swap' /etc/fstab; then
    sudo sed -i '/\s\+swap\s\+/d' /etc/fstab
    echo -e "\033[1;32m✅ Swap entry removed from /etc/fstab.\033[0m"
else
    echo -e "\033[1;32m✅ No swap entry found in /etc/fstab.\033[0m"
fi

# Get control plane IP and hostname
CONTROL_PLANE_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
NODE_NAME=$(hostnamectl --static)

# Pull Kubernetes images
echo -e "\n\033[1;33m📥 Pulling required Kubernetes images...\033[0m"
sudo kubeadm config images pull || { echo -e "\n\033[1;31m❌ Failed to pull Kubernetes images. Exiting...\033[0m"; exit 1; }
echo -e "\033[1;32m✅ Kubernetes images pulled successfully.\033[0m".

# Initialize Kubernetes control plane
echo -e "\n\033[1;34m🚀 Initializing Kubernetes control plane...\033[0m"
sudo kubeadm init \
  --control-plane-endpoint "${CONTROL_PLANE_IP}:6443" \
  --upload-certs \
  --pod-network-cidr 192.168.0.0/16 \
  --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
  --node-name "${NODE_NAME}" \
  --cri-socket=unix:///var/run/containerd/containerd.sock || { echo -e "\n\033[1;31m❌ kubeadm init failed. Exiting...\033[0m"; exit 1; }
echo -e "\033[1;32m✅ Kubernetes control plane initialized successfully.\033[0m"

echo -e "\n\033[1;36m🎉 kubeadm-init.sh script is completed!\033[0m"

