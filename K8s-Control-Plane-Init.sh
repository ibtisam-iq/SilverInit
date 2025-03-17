#!/bin/bash

# ╔════════════════════════════════════════════════════╗
# ║   SilverInit - Kubernetes Control Plane Setup      ║
# ║     (c) 2025 Muhammad Ibtisam Iqbal                ║
# ║     License: MIT                                   ║
# ╚════════════════════════════════════════════════════╝
#
# 📌 Description:
# This script automates the initialization of the first Kubernetes control plane node.
# It configures the OS, installs the container runtime, and initializes the control plane.
#
# 🚀 Usage:
#   curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/K8s-Control-Plane-Init.sh | sudo bash
#
# 📜 License: MIT | 🌐 https://github.com/ibtisam-iq/SilverInit

set -euo pipefail  # Exit on errors, unset variables, and pipe failures
trap 'echo -e "\n\033[1;31m❌ Error occurred at line $LINENO. Exiting...\033[0m\n" && exit 1' ERR

# Define repository URL
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# ==================================================
# 🚀 Preflight Check & System Preparation
# ==================================================
echo -e "\n\033[1;34m🚀 Running K8s-Node-Init.sh script...\033[0m"
bash <(curl -sL "$REPO_URL/K8s-Node-Init.sh") || { echo -e "\n\033[1;31m❌ Failed to execute K8s-Node-Init.sh. Exiting...\033[0m"; exit 1; }
echo -e "\n\033[1;32m✅ K8s-Node-Init.sh executed successfully.\033[0m\n"

# ==================================================
# 🔧 Control Plane Initialization
# ==================================================

# Disable swap permanently
echo -e "\n\033[1;33m🔧 Disabling swap...\033[0m"
sudo swapoff -a
sudo sed -i '/\s\+swap\s\+/d' /etc/fstab
echo -e "\033[1;32m✅ Swap disabled successfully.\033[0m"

# Restart container runtime
echo -e "\n\033[1;33m🔄 Restarting containerd...\033[0m"
sudo systemctl restart containerd
echo -e "\033[1;32m✅ Containerd restarted successfully.\033[0m"

# Start and enable kubelet
echo -e "\n\033[1;33m🔄 Restarting kubelet service...\033[0m"
sudo systemctl enable --now kubelet
sudo systemctl restart kubelet
echo -e "\033[1;32m✅ Kubelet is active and running.\033[0m"

# Check required ports
echo -e "\n\033[1;33m🔍 Checking necessary ports...\033[0m"
sleep 60  # Allow services to stabilize
if ! sudo netstat -tulnp | grep -E 'containerd|6443'; then
  echo -e "\n\033[1;31m❌ Required ports are not open. Exiting...\033[0m";
  exit 1;
fi
echo -e "\033[1;32m✅ Required ports are open.\033[0m"

# Pull Kubernetes images
echo -e "\n\033[1;33m📥 Pulling required Kubernetes images...\033[0m"
sudo kubeadm config images pull || { echo -e "\n\033[1;31m❌ Failed to pull Kubernetes images. Exiting...\033[0m"; exit 1; }
echo -e "\033[1;32m✅ Kubernetes images pulled successfully.\033[0m"

# Get control plane IP and hostname
CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')
NODE_NAME=$(hostnamectl --static)

# Initialize Kubernetes control plane
echo -e "\n\033[1;34m🚀 Initializing Kubernetes control plane...\033[0m"
sudo kubeadm init \
  --control-plane-endpoint "${CONTROL_PLANE_IP}:6443" \
  --upload-certs \
  --pod-network-cidr 192.168.0.0/16 \
  --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
  --node-name "${NODE_NAME}" \
  --cri-socket=unix:///var/run/containerd/containerd.sock || { echo -e "\n\033[1;31m❌ kubeadm init failed. Exiting...\033[0m"; exit 1; }

# Control plane initialization complete
echo -e "\033[1;32m✅ Kubernetes control plane initialized successfully.\033[0m"

# Configure kubectl access
echo -e "\n\033[1;33m🔹 Configuring kubectl access...\033[0m"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo -e "\033[1;32m✅ Kubectl configured successfully.\033[0m"

# Deploy Calico CNI
echo -e "\n\033[1;34m🚀 Deploying Calico network plugin...\033[0m"
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml || { echo -e "\n\033[1;31m❌ Failed to apply Calico CNI. Exiting...\033[0m"; exit 1; }
echo -e "\033[1;32m✅ Calico network plugin deployed successfully.\033[0m"

# Wait for Kubernetes components to be fully up
echo -e "\n\033[1;33m⏳ Waiting for cluster components to be ready...\033[0m"

READY=false
TIMEOUT=600   # Timeout in seconds (10 minutes)
INTERVAL=30   # Check every 30 seconds
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
    NODES_STATUS=$(kubectl get nodes --no-headers 2>/dev/null | awk '{print $2}')
    PODS_STATUS=$(kubectl get pods -A --no-headers 2>/dev/null | awk '{print $4}' | grep -v "Running\|Completed")

    if [[ $NODES_STATUS == "Ready" && -z "$PODS_STATUS" ]]; then
        READY=true
        break
    fi

    echo -e "\033[1;33m⏳ Cluster is still initializing... waiting ($ELAPSED/$TIMEOUT seconds)\033[0m"
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ "$READY" = false ]; then
    echo -e "\033[1;31m❌ Cluster did not become ready in time. Exiting...\033[0m"
    exit 1
fi

echo -e "\033[1;32m✅ Cluster components are now stable.\033[0m"

# Verify cluster status
echo -e "\n\033[1;33m🔍 Checking Kubernetes cluster status...\033[0m"
kubectl get nodes
kubectl get pods -A
kubectl get pods -n kube-system
echo -e "\033[1;32m✅ Kubernetes cluster is running successfully.\033[0m"

# Final message
echo -e "\n\033[1;36m🎉 Kubernetes control plane setup is complete!\033[0m"
echo -e "\033[1;32m✅ The control plane components may take a few more minutes to stabilize.\033[0m"
echo -e "\033[1;32m✅ You can now join worker nodes to this cluster using the kubeadm join command.\033[0m"
echo -e "\n\033[1;36m🎉 Happy Kuberneting! 🚀\033[0m\n"

# ==================================================
# 🎉 Setup Complete! Thank You! 🙌
# ==================================================
echo -e "\n\033[1;33m✨  Thank you for choosing SilverInit - Muhammad Ibtisam 🚀\033[0m\n"
echo -e "\033[1;32m💡 Automation is not about replacing humans; it's about freeing them to be more human—to create, innovate, and lead. \033[0m\n"