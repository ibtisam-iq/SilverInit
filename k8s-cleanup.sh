#!/bin/bash

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

EXISTING_FILES=(
    "/etc/kubernetes/"
    "/var/lib/etcd"
    "$HOME/.kube/"
)
EXISTING_SERVICES=(
    "kubelet"
    "containerd"
)
EXISTING_PORTS=(6443 10259 10257 10250 2379 2380)

# Check for existing resources
found_existing=false

echo -e "\n\033[1;33m🔍 Checking for existing Kubernetes resources...\033[0m"

# Check for existing directories
for file in "${EXISTING_FILES[@]}"; do
    if [ -e "$file" ]; then
        echo -e "\033[1;31m⚠️  Found existing Kubernetes directory: $file\033[0m"
        found_existing=true
    fi
done

# Check if services are running
for service in "${EXISTING_SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo -e "\033[1;31m⚠️  Service is running: $service\033[0m"
        found_existing=true
    fi
done

# Check if required ports are in use
for port in "${EXISTING_PORTS[@]}"; do
    if sudo netstat -tulnp | grep -q ":$port "; then
        echo -e "\033[1;31m⚠️  Port $port is already in use\033[0m"
        found_existing=true
    fi
done

# If any conflicting resources are found, ask user for action
if [ "$found_existing" = true ]; then
    read -r -p "⚠️  Conflicting resources found! Do you want to delete them? (y/n): " answer > /dev/tty
    if [[ ! $answer =~ ^[Yy]$ ]]; then
        echo -e "\n\033[1;31m❌ Cluster initialization aborted. You must remove existing resources first.\033[0m"
        exit 1
    fi
fi

# ==================================================
# 🛑 Cleaning Up Existing Resources
# ==================================================

# Stop running services
echo -e "\n\033[1;33m🛑 Stopping Kubernetes-related services...\033[0m"
for service in "${EXISTING_SERVICES[@]}"; do
    sudo systemctl stop "$service" || true
done
echo -e "\033[1;32m✅ Services stopped successfully.\033[0m"

# Delete old Kubernetes files
echo -e "\n\033[1;33m🧹 Removing existing Kubernetes configuration...\033[0m"
for file in "${EXISTING_FILES[@]}"; do
    sudo rm -rf "$file" || true
done
echo -e "\033[1;32m✅ Old Kubernetes configurations removed.\033[0m"

# Free up ports
echo -e "\n\033[1;33m🔍 Releasing occupied ports...\033[0m"
for port in "${EXISTING_PORTS[@]}"; do
    sudo fuser -k ${port}/tcp || true
done
echo -e "\033[1;32m✅ Ports freed successfully.\033[0m"

# Kill any remaining Kubernetes processes
echo -e "\n\033[1;33m🔍 Killing any remaining Kubernetes-related processes...\033[0m"
sudo pkill -9 kube-apiserver || true
sudo pkill -9 etcd || true
sudo pkill -9 kube-controller || true
sudo pkill -9 kube-scheduler || true
sudo pkill -9 kubelet || true
sudo pkill -9 containerd || true
echo -e "\033[1;32m✅ Processes terminated.\033[0m"

# Reset Kubernetes setup
echo -e "\n\033[1;33m🧹 Resetting Kubernetes installation...\033[0m"
sudo kubeadm reset -f || true
echo -e "\033[1;32m✅ Kubernetes reset complete.\033[0m"