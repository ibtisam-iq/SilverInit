#!/bin/bash

# SilverInit - Kubernetes First Control Plane Initializer
# -------------------------------------------------
# This script automates the setup of the first Kubernetes control plane node using kubeadm.
# It executes a sequence of scripts to configure the OS, install the container runtime,
# and initialize the control plane.
# It runs on the first node in the cluster, typically the master node.

# The following scripts are executed in sequence:
# 1. K8s-Node-Init.sh (which internally runs containerd-setup.sh)
# 2. This script (K8s-Control-Plane-Init.sh)

set -euo pipefail  # Exit on errors, unset variables, and pipe failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running K8s-Node-Init.sh script..."
bash <(curl -sL "$REPO_URL/K8s-Node-Init.sh") || { echo -e "\n❌ Failed to execute K8s-Node-Init.sh. Exiting...\n"; exit 1; }
echo -e "\n✅ K8s-Node-Init.sh executed successfully.\n"

echo -e "\n🚀 Running K8s-Control-Plane-Init.sh script..."

# Ensure swap is disabled (Kubernetes does not work with swap enabled)
echo -e "\n🔹 Disabling swap before initializing the control plane..."
sudo swapoff -a
sudo sed -i '/\s\+swap\s\+/d' /etc/fstab  # Make it persistent across reboots

# Restart container runtime
echo -e "\n🔹 Restarting containerd before initializing control plane..."
sudo systemctl restart containerd

# Start and enable kubelet
echo -e "\n🔹 Restarting Kubernetes service before initializing control plane..."
sudo systemctl enable --now kubelet
sudo systemctl restart kubelet

# Verify required ports are listening
echo -e "\n🔹 Checking if containerd and Kubernetes API server ports are open before initializing control plane..."
sleep 60  # Wait for services to start
sudo netstat -tulnp | grep -E 'containerd|6443' || { echo -e "\n❌ Required ports are not open. Exiting...\n"; exit 1; }

# Pull Kubernetes control plane images
echo -e "\n🔹 Pulling required Kubernetes images before initializing control plane..."
sudo kubeadm config images pull || { echo -e "\n❌ Failed to pull Kubernetes images. Exiting...\n"; exit 1; }

# Get the control plane IP and node name
CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')
NODE_NAME=$(hostnamectl --static)

# Initialize Kubernetes control plane
echo -e "\n🚀 Initializing Kubernetes control plane..."
sudo kubeadm init \
  --control-plane-endpoint "${CONTROL_PLANE_IP}:6443" \
  --upload-certs \
  --pod-network-cidr 192.168.0.0/16 \
  --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
  --node-name "${NODE_NAME}" \
  --cri-socket=unix:///var/run/containerd/containerd.sock || { echo -e "\n❌ kubeadm init failed. Exiting...\n"; exit 1; }

# Wait for the control plane components to stabilize
echo -e "\n⏳ Waiting for 100 seconds to stabilize the cluster components..."
sleep 120  # Give time for pods to initialize

# Configure kubectl for the current user
echo -e "\n🔹 Setting up kubectl access..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Calico CNI
echo -e "\n🚀 Deploying Calico network plugin..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml || { echo -e "\n❌ Failed to apply Calico CNI. Exiting...\n"; exit 1; }

# Verify cluster setup
echo -e "\n🔹 Checking Kubernetes cluster status..."
kubectl get nodes
kubectl get pods -A
kubectl get pods -n kube-system

echo -e "\n🎉 Kubernetes control plane setup is complete!"
echo -e "✅ The control plane components may take a few more minutes to stabilize."
echo -e "✅ You can now join worker nodes to this cluster using the kubeadm join command.\n"
echo -e "🎉 Happy Kuberneting! 🚀\n"