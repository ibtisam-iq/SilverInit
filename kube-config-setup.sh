#!/bin/bash

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected
set -u  # Treat unset variables as an error

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

USER_HOME=$(eval echo ~$SUDO_USER)
# Ensure ~/.kube/config exists before proceeding
while [ ! -f "$USER_HOME/.kube/config" ]; do
    echo -e "\n🔍 ~/.kube/config not found. Setting it up..."
    sudo mkdir -p $USER_HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $USER_HOME/.kube/config
    sudo chown $SUDO_USER:$SUDO_USER $USER_HOME/.kube/config

    # Wait for a second before rechecking (prevents infinite fast loop)
    sleep 1
done

echo -e "\n✅ ~/.kube/config is set."
sudo ls -la $USER_HOME/.kube/config

# Ensure KUBECONFIG is set
export KUBECONFIG=$USER_HOME/.kube/config
echo -e "\n📌 KUBECONFIG set to $KUBECONFIG"

# Verify kubectl access
kubectl cluster-info || { echo "⚠️ Failed to connect to Kubernetes cluster"; exit 1; }

echo -e "\n\033[1;32m✅ kubectl configured successfully.\033[0m"

echo -e "\n\033[1;36m🎉 kube-config-setup.sh script is completed!\033[0m"