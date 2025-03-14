#!/bin/bash

# SilverInit - Kubernetes Control Plane Initializer
# -------------------------------------------------
# This script automates the setup of the first Kubernetes control plane node using kubeadm.
# It executes a sequence of scripts to configure the OS, install container runtime, 
# and initialize the control plane.

# Exit immediately if a command exits with a non-zero status
set -e

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# Ensure the script is running on Ubuntu
[[ -f /etc/os-release ]] && . /etc/os-release
if [[ "$ID" != "ubuntu" ]]; then
    echo "This script is for Ubuntu only."
    exit 1
fi

# Ensure curl is installed
if ! command -v curl &>/dev/null; then
    echo "⚠️ 'curl' not found. Installing..."
    sudo apt update -qq && sudo apt install -qy curl
    echo "✅ 'curl' installed successfully."
fi

# Execute scripts in sequence
bash <(curl -sL "$REPO_URL/os-setup-for-k8s-cluster.sh")
bash <(curl -sL "$REPO_URL/containerd-setup.sh")

echo "✅ The Worker Node is ready to join the Kubernetes cluster!"