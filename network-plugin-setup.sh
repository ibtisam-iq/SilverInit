#!/bin/bash

# 📌 Description:
# This script automates the deployment of the Calico network plugin for Kubernetes.
# It assumes that the Kubernetes cluster is already initialized and running.
# The script will install the Calico network plugin and configure it for use with the Kubernetes cluster.

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/k8s-start-services.sh | sudo bash

# Deploying Calico CNI
echo -e "\n\033[1;34m🚀 Deploying Calico network plugin...\033[0m"
# kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml || { echo -e "\n\033[1;31m❌ Failed to apply Calico CNI. Exiting...\033[0m"; exit 1; }
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/operator-crds.yaml
sleep 10
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/custom-resources.yaml -O
# Path to your file
FILE="custom-resources.yaml"

# Backup the original
cp "$FILE" "${FILE}.bak"

# Update the CIDR using sed
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.244.0.0\/16/' "$FILE"

# Confirm update
echo "✅ CIDR updated to 10.244.0.0/16 in $FILE"

kubectl apply -f custom-resources.yaml || { echo -e "\n\033[1;31m❌ Failed to apply Calico CNI. Exiting...\033[0m"; exit 1; }

echo -e "\033[1;32m✅ Calico network plugin deployed successfully.\033[0m"

# Validate CNI plugin installation
echo -e "\n\033[1;34m✅ Validating CNI plugin installation...\033[0m"
sleep 60
sudo systemctl restart containerd
sudo systemctl restart kubelet
sudo ls /opt/cni/bin/ || { echo -e "\n\033[1;31m❌ CNI plugins not found. Exiting...\033[0m"; exit 1; }
echo
sudo ls /etc/cni/net.d/

echo -e "\n\033[1;32m✅ CNI plugins found.\033[0m"

echo -e "\n\033[1;36m🎉 network-plugin-setup.sh script is completed!\033[0m"
