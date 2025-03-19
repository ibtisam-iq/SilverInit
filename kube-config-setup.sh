#!/bin/bash

# Ensure ~/.kube/config exists before proceeding
while [ ! -f "$HOME/.kube/config" ]; do
    echo -e "\n🔍 ~/.kube/config not found. Setting it up..."
    sudo mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Wait for a second before rechecking (prevents infinite fast loop)
    sleep 1
done

echo -e "\n✅ ~/.kube/config is set."
sudo ls -la $HOME/.kube/config

# Ensure KUBECONFIG is set
export KUBECONFIG=$HOME/.kube/config
echo -e "\n📌 KUBECONFIG set to $KUBECONFIG"

# Verify kubectl access
kubectl cluster-info || { echo "⚠️ Failed to connect to Kubernetes cluster"; exit 1; }

echo -e "\n\033[1;32m✅ kubectl configured successfully.\033[0m"

echo -e "\n\033[1;36m🎉 kube-config-setup.sh script is completed!\033[0m"