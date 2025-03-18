#!/bin/bash

set -euo pipefail
trap 'echo -e "\n\033[1;31m❌ Error at line $LINENO. Exiting...\033[0m"; exit 1' ERR

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# Logging setup
LOG_FILE="/var/log/k8s-setup.log"
echo "$(date) - Starting Kubernetes Control Plane Setup" | tee -a "$LOG_FILE"

# ==================================================
# Restarting Required Services
# ==================================================

# Ensure required services are running
echo -e "\n\033[1;33m🔍 Ensuring necessary services are running...\033[0m"
sudo systemctl start containerd kubelet || true
sudo systemctl enable containerd kubelet --now || true
for service in containerd kubelet; do
    until systemctl is-active --quiet "$service"; do
        echo -e "\033[1;33m⏳ Waiting for $service to start...\033[0m"
        sleep 10
    done
    echo -e "\033[1;32m✅ $service is running.\033[0m"
done

# Check required ports
local timeout=60
local elapsed=0
echo "⏳ Waiting for Kubernetes API server to be ready..." | tee -a "$LOG_FILE"
while ! sudo netstat -tulnp | grep -E "6443" &>/dev/null; do
    if [[ $elapsed -ge $timeout ]]; then
        echo "❌ Kubernetes API server did not start within $timeout seconds. Exiting..." | tee -a "$LOG_FILE"
        exit 1
    fi
    echo "⏳ Still waiting... ($elapsed s elapsed)" | tee -a "$LOG_FILE"
    sleep 5
    ((elapsed+=5))
done
echo -e "\033[1;32m✅ Kubernetes API server is running.\033[0m" | tee -a "$LOG_FILE"