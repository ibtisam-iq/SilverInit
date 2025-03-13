#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Just before running kubeadm init
sudo swapoff -a
sudo systemctl restart containerd
echo "Starting Kubernetes service..."
sudo systemctl start kubelet
sudo systemctl enable kubelet --now
sudo ss -l | grep containerd

# Pull Kubernetes images
echo "Pulling required Kubernetes images..."
sudo kubeadm config images pull || { echo "Failed to pull Kubernetes images."; exit 1; }

# Initialize the Kubernetes control plane
echo "Initializing Kubernetes control plane..."
CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')
NODE_NAME=$(hostnamectl --static)

sudo kubeadm init \
  --control-plane-endpoint "${CONTROL_PLANE_IP}:6443" \
  --upload-certs \
  --pod-network-cidr 192.168.0.0/16 \
  --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
  --node-name "${NODE_NAME}" \
  --cri-socket=unix:///var/run/containerd/containerd.sock

# Configure kubectl for the current user
echo "Setting up kubectl access..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Calico network plugin
echo "Deploying Calico CNI..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Verify cluster status
echo "Verifying Kubernetes cluster setup..."
kubectl get nodes
sleep 60
kubectl get pods -A
kubectl get pods -n kube-system

echo "Kubernetes control node plane setup is complete! 🎉"
echo "Please note that the control plane components may take a few minutes to stabilize."
echo "You can now join worker nodes to this cluster using the kubeadm join command."
echo "Happy Kuberneting! 🚀"