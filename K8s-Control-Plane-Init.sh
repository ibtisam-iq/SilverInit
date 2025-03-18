#!/bin/bash

# ╔════════════════════════════════════════════════════╗
# ║   SilverInit - Kubernetes Control Plane Setup      ║
# ║     (c) 2025 Muhammad Ibtisam Iqbal                ║
# ║     License: MIT                                   ║
# ╚════════════════════════════════════════════════════╝
#
# 📌 Description:
# This script automates the initialization of the first Kubernetes control plane node.
#
# 🚀 Usage:
#   curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/K8s-Control-Plane-Init.sh | sudo bash
#
# 📜 License: MIT | 🌐 https://github.com/ibtisam-iq/SilverInit

set -euo pipefail
trap 'echo -e "\n\033[1;31m❌ Error at line $LINENO. Exiting...\033[0m"; exit 1' ERR

# Debug mode (set DEBUG=true to enable)
DEBUG=${DEBUG:-false}
if [ "$DEBUG" == "true" ]; then
    set -x
fi

# Logging setup
LOG_FILE="/var/log/k8s-setup.log"
echo "$(date) - Starting Kubernetes Control Plane Setup" | tee -a "$LOG_FILE"

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# List of scripts to execute
SCRIPTS=(
    "K8s-Node-Init.sh"
    "k8s-cleanup.sh"
    "k8s-start-services.sh"
)

# 🚀 Executing Scripts
for script in "${SCRIPTS[@]}"; do
    echo -e "\n\033[1;34m🚀 Running $script script...\033[0m"
    bash <(curl -fsSL "$REPO_URL/$script") || { echo -e "\n\033[1;31m❌ Failed to execute $script. Exiting...\033[0m\n"; exit 1; }
    echo -e "\033[1;32m✅ Successfully executed $script.\033[0m\n"
done

# 🔧 System Configuration
echo -e "\n\033[1;33m🔧 Disabling swap...\033[0m"
sudo swapoff -a
if grep -q 'swap' /etc/fstab; then
    sudo sed -i '/\s\+swap\s\+/d' /etc/fstab
    echo -e "\033[1;32m✅ Swap entry removed from /etc/fstab.\033[0m"
else
    echo -e "\033[1;32m✅ No swap entry found in /etc/fstab.\033[0m"
fi

# ==================================================
# 🚀 Proceeding with Cluster Initialization
# ==================================================

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
  --cri-socket=unix:///var/run/containerd/containerd.sock || { echo -e "\n\033[1;31m❌ kubeadm init failed. Exiting...\033[0m"; exit 1; } | tee -a "$LOG_FILE"
echo -e "\033[1;32m✅ Kubernetes control plane initialized successfully.\033[0m"

# Configure kubectl
echo -e "\n\033[1;33m🔧 Configuring kubectl...\033[0m"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo -e "\033[1;32m✅ kubectl configured successfully.\033[0m"

# Deploying Calico CNI
echo -e "\n\033[1;34m🚀 Deploying Calico network plugin...\033[0m"
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml || { echo -e "\n\033[1;31m❌ Failed to apply Calico CNI. Exiting...\033[0m"; exit 1; }
echo -e "\033[1;32m✅ Calico network plugin deployed successfully.\033[0m"

# Readiness Check
echo -e "\n\033[1;33m⏳ Waiting for the control plane and pods to become ready...\033[0m"
sudo bash <(curl -fsSL "$REPO_URL/k8s-readiness-check.sh") || { echo -e "\n\033[1;31m❌ Cluster not ready. Exiting...\033[0m"; exit 1; }

# Verifying Cluster Status
echo -e "\n\033[1;33m🩺 Checking Kubernetes cluster status...\033[0m"
kubectl get nodes -o wide | tee -a "$LOG_FILE"
kubectl get pods -A -o wide | tee -a "$LOG_FILE"

# ==================================================
# 🎉 Final Messages
# ==================================================
echo -e "\n\033[1;36m🎉 Kubernetes control plane setup is complete!\033[0m"
echo -e "\033[1;32m✅ You can now join worker nodes using the kubeadm join command.\033[0m"

echo -e "\n\033[1;33m✨ Thank you for using SilverInit - Muhammad Ibtisam 🚀\033[0m"
echo -e "\033[1;32m💡 Automation is about freeing humans to innovate! \033[0m\n"