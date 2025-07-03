#!/bin/bash

# ╔════════════════════════════════════════════════════╗
# ║   SilverInit - Kubernetes Control Plane Setup      ║
# ║     (c) 2025 Muhammad Ibtisam Iqbal                ║
# ║     License: MIT                                   ║
# ╚════════════════════════════════════════════════════╝
#
# 📌 Description:
# This script automates the initialization of the first Kubernetes control plane node.
#
# 🚀 Usage:
#   curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/K8s-Control-Plane-Init.sh | sudo bash
#
# 📜 License: MIT | 🌐 https://github.com/ibtisam-iq/SilverInit

set -euo pipefail
trap 'echo -e "\n\033[1;31m❌ Error at line $LINENO. Exiting...\033[0m"; exit 1' ERR

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# List of scripts to execute
SCRIPTS=(
    "K8s-Node-Init.sh"
    "k8s-cleanup.sh"
    "k8s-start-services.sh"
    "kubeadm-init.sh"
    "kube-config-setup.sh"
)

# 🚀 Executing Scripts
for script in "${SCRIPTS[@]}"; do
    echo -e "\n\033[1;34m🚀 Running $script script...\033[0m"
    bash <(curl -fsSL "$REPO_URL/$script") || { echo -e "\n\033[1;31m❌ Failed to execute $script. Exiting...\033[0m\n"; exit 1; }
    echo -e "\033[1;32m✅ Successfully executed $script.\033[0m\n"
done

echo
echo -e "\n\033[1;34m🚀 Your Kubernetes Control Plane is now ready!\033[0m"
echo -e "\033[1;32mTo complete the setup and begin using your cluster, please follow these final steps:\033[0m"
echo -e "\033[1;37m────────────────────────────────────────────────────────────\033[0m"

# ==================================================
# 🎉 Final Messages
# ==================================================

# Step 1: Show join command for worker nodes
echo -e "\n\033[1;35m🔗 Step 1: Join Worker Nodes\033[0m"
JOIN_CMD=$(kubeadm token create --print-join-command 2>/dev/null || echo "⚠️ kubeadm join command not available. Make sure 'kubeadm init' ran successfully.")
echo -e "\033[1;36m$JOIN_CMD\033[0m"

# Step 2: Deploy Calico CNI plugin
echo -e "\n\033[1;35m🌐 Step 2: Deploy the Calico Network Plugin\033[0m"
echo -e "\033[1;36mcurl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/calico-setup.sh | bash\033[0m"

# Step 3: Verify the cluster status
echo -e "\n\033[1;35m🔍 Step 3: Verify the Cluster Status\033[0m"
echo -e "\033[1;36mkubectl get nodes -o wide\033[0m"

# Final closing message
echo -e "\n\033[1;33m✨ Thank you for using SilverInit - Muhammad Ibtisam 🚀\033[0m"
echo -e "\033[1;32m💡 Automation is about freeing humans to innovate!\033[0m\n"
