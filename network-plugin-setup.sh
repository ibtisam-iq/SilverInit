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
sleep 30
# kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml || { echo -e "\n\033[1;31m❌ Failed to apply Calico CNI. Exiting...\033[0m"; exit 1; }
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
sed -i 's/# - name: CALICO_IPV4POOL_CIDR/- name: CALICO_IPV4POOL_CIDR/' calico.yaml
sed -i 's/#   value: "192.168.0.0\/16"/  value: "10.244.0.0\/16"/' calico.yaml
kubectl apply -f calico.yaml || { echo -e "\n\033[1;31m❌ Failed to apply Calico CNI. Exiting...\033[0m"; exit 1; }

echo -e "\033[1;32m✅ Calico network plugin deployed successfully.\033[0m"

# Validate CNI plugin installation
echo -e "\n\033[1;34m✅ Validating CNI plugin installation...\033[0m"
sleep 60
sudo ls /opt/cni/bin/ || { echo -e "\n\033[1;31m❌ CNI plugins not found. Exiting...\033[0m"; exit 1; }
echo -e "\n\033[1;32m✅ CNI plugins found.\033[0m"

echo -e "\n\033[1;36m🎉 network-plugin-setup.sh script is completed!\033[0m"