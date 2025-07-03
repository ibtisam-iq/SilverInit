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


# ==================================================
# 🎉 Final Messages
# ==================================================
echo -e "\n\033[1;36m🎉 Kubernetes control plane setup is complete!\033[0m"
echo -e "\033[1;32m✅ You can now join worker nodes using the kubeadm join command.\033[0m"

echo -e "\n\033[1;33m✨ Thank you for using SilverInit - Muhammad Ibtisam 🚀\033[0m"
echo -e "\033[1;32m💡 Automation is about freeing humans to innovate! \033[0m\n"
