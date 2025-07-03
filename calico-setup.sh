#!/bin/bash

# 📌 Description:
# This script automates the deployment of the Calico network plugin for Kubernetes.
# It assumes that the Kubernetes cluster is already initialized and running.
# The script installs the Calico CNI and configures it using the dynamically sourced POD_CIDR.

set -e
set -o pipefail
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# 🔗 Fetch dynamic cluster environment variables
echo -e "\n\033[1;36m🔗 Fetching cluster environment variables...\033[0m"
eval "$(curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/cluster-params.sh)"

echo -e "📦 POD_CIDR to be configured: $POD_CIDR"

# 🔄 Start Kubernetes services
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/k8s-start-services.sh | sudo bash

# 🚀 Deploying Calico CNI
echo -e "\n\033[1;34m🚀 Deploying Calico network plugin...\033[0m"
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/operator-crds.yaml
sleep 10
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/tigera-operator.yaml

# ⬇️ Download custom Calico config
curl -sO https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/custom-resources.yaml
FILE="custom-resources.yaml"

# 🛠️ Patch the CIDR dynamically
cp "$FILE" "${FILE}.bak"
sed -i "s|cidr: 192.168.0.0/16|cidr: ${POD_CIDR}|" "$FILE"
echo "✅ CIDR updated to ${POD_CIDR} in $FILE"

# 📤 Apply the Calico configuration
kubectl apply -f "$FILE" || { echo -e "\n\033[1;31m❌ Failed to apply Calico CNI. Exiting...\033[0m"; exit 1; }

echo -e "\n\033[1;32m✅ Calico network plugin deployed successfully.\033[0m"

# 🔎 Validate CNI plugin installation
echo -e "\n\033[1;34m🔍 Validating CNI plugin installation...\033[0m"
sleep 60
sudo systemctl restart containerd kubelet

sudo ls /opt/cni/bin/ || { echo -e "\n\033[1;31m❌ CNI plugins not found. Exiting...\033[0m"; exit 1; }
echo
sudo ls -l /etc/cni/net.d/
echo -e "\n\033[1;32m✅ CNI plugins found.\033[0m"

echo -e "\n\033[1;36m🎉 calico-setup.sh script is completed!\033[0m"

