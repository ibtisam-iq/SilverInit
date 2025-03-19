#!/bin/bash

# Ensure ~/.kube/config exists before proceeding
while [ ! -f "$HOME/.kube/config" ]; do
    echo "🔍 ~/.kube/config not found. Setting it up..."
    sudo mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Wait for a second before rechecking (prevents infinite fast loop)
    sleep 1
done

echo "✅ ~/.kube/config is set."

# Ensure KUBECONFIG is set
export KUBECONFIG=$HOME/.kube/config
echo "📌 KUBECONFIG set to $KUBECONFIG"

# Verify kubectl access
kubectl cluster-info || { echo "⚠️ Failed to connect to Kubernetes cluster"; exit 1; }

echo -e "\033[1;32m✅ kubectl configured successfully.\033[0m"