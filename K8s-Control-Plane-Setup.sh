#!/bin/bash

# SilverInit - Kubernetes Control Plane Initializer
# -------------------------------------------------
# This script automates the setup of the first Kubernetes control plane node using kubeadm.
# It executes a sequence of scripts to configure the OS, install container runtime, 
# and initialize the control plane.

# GitHub repo details
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/K8s-Control-Plane-Setup.sh"

# List of scripts to execute
SCRIPTS=(
    "01-os-setup.sh"          # OS configurations and dependencies
    "02-containerd-setup.sh"  # Install and configure Containerd runtime
    "03-kubeadm-init.sh"      # Initialize Kubernetes control plane with kubeadm
)

echo "🚀 Initializing Kubernetes Control Plane with kubeadm..."

# Execute each script in order
for script in "${SCRIPTS[@]}"; do
    echo "▶ Running $script..."
    bash <(curl -sL "$REPO_URL/$script") || { echo "❌ Error executing $script"; exit 1; }
done

echo "✅ Kubernetes control plane initialization completed successfully!"

echo "Happy Kuberneting! 🚀"