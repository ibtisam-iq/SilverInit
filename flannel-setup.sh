#!/bin/bash

# 📌 Description:
# This script automates the deployment of the Flannel network plugin for Kubernetes.
# It fetches the official manifest, patches the Pod CIDR (if necessary), and applies the configuration.
# It assumes the Kubernetes cluster is already initialized and running.

set -e
set -o pipefail
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# 🔗 Fetch dynamic cluster environment variables
echo -e "\n\033[1;36m🔗 Fetching cluster environment variables...\033[0m"
eval "$(curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/cluster-params.sh)"

echo -e "📦 POD_CIDR to be configured: $POD_CIDR"

# 🔄 Start Kubernetes services
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/k8s-start-services.sh | sudo bash

# ⬇️ Download the official Flannel manifest
echo -e "\n\033[1;34m📥 Downloading official Flannel manifest...\033[0m"
curl -LO https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

FILE="kube-flannel.yml"

# 🛠️ Patch the CIDR in net-conf.json
cp "$FILE" "${FILE}.bak"
sed -i "s#\"Network\": *\"[^\"]*\"#\"Network\": \"${POD_CIDR}\"#" "$FILE"
echo "✅ CIDR updated to ${POD_CIDR} in $FILE"

# ℹ️ CIDR_RANGE explanation
# Network defines the CIDR block that Flannel uses to allocate pod IP addresses.
# If not explicitly set, it defaults to 10.244.0.0/16 in the official manifest.

# 📤 Apply the Flannel CNI configuration
echo -e "\n\033[1;34m🚀 Applying Flannel network configuration...\033[0m"
kubectl apply -f "$FILE" || { echo -e "\n\033[1;31m❌ Failed to apply Flannel CNI. Exiting...\033[0m"; exit 1; }

# 🔄 Restart container runtime and kubelet
echo -e "\n\033[1;36m🔁 Restarting system services...\033[0m"
sudo systemctl restart containerd kubelet

# 🔎 Validate CNI plugin installation
echo -e "\n\033[1;34m🔍 Validating CNI plugin installation...\033[0m"
sleep 30
sudo ls /opt/cni/bin/ || { echo -e "\n\033[1;31m❌ CNI plugins not found. Exiting...\033[0m"; exit 1; }
echo
sudo ls -l /etc/cni/net.d/
echo -e "\n\033[1;32m✅ CNI plugins found.\033[0m"

echo -e "\n\033[1;36m🎉 flannel-setup.sh script is completed!\033[0m"
