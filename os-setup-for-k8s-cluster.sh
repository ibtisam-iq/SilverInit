#!/bin/bash

# SilverInit - Get the Nodes Ready for Kubernetes Cluster
# -------------------------------------------------
# This script prepares nodes for a Kubernetes cluster by:
# - Disabling swap
# - Setting the hostname
# - Installing required dependencies
# - Configuring sysctl settings for Kubernetes networking
# - Adding the Kubernetes APT repository and installing kubeadm, kubelet, and kubectl.

set -e  # Exit immediately if a command fails
trap 'echo -e "\n❌ An error occurred. Exiting..."; exit 1' ERR  # Handle failures gracefully

echo -e "\n🚀 Starting Kubernetes Node Preparation...\n"

# Update system and install necessary dependencies
echo -e "\n🔄 Updating package lists and installing dependencies..."
sudo apt update -qq && sudo apt install -yq net-tools apt-transport-https ca-certificates curl gpg > /dev/null 2>&1

# Disable swap permanently
echo -e "\n🔧 Disabling swap..."
sudo swapoff -a
sudo sed -i '/\s\+swap\s\+/d' /etc/fstab

# Prompt user for a hostname (leave empty to keep the current one)
read -p "🔹 Please enter hostname for this node (leave empty to keep current): " HOSTNAME < /dev/tty

# Set hostname if provided

if [[ -n "$HOSTNAME" ]]; then
    echo "🖥️ Setting hostname to: $HOSTNAME"
    hostnamectl set-hostname "$HOSTNAME"
else
    echo "ℹ️ Keeping the existing hostname: $(hostname)"
fi

# Display system information before Kubernetes setup
echo -e "\n📊 System Information Before Kubernetes Setup:"
echo "---------------------------------------------"
echo "🔹 Hostname: $(hostnamectl --static)"
# echo "🔹 Machine UUID: $(sudo cat /sys/class/dmi/id/product_uuid)"
if [[ -r /sys/class/dmi/id/product_uuid ]]; then
    echo "🔹 Machine UUID: $(sudo cat /sys/class/dmi/id/product_uuid)"
else
    echo "🔹 Machine UUID: Access Denied (Require root privileges)"
fi
echo "🔹 Private IP: $(hostname -I | awk '{print $1}')"
echo "🔹 Public IP: $(curl -s ifconfig.me || curl -s https://ipinfo.io/ip || echo 'Unavailable')"
echo -e "🔹 MAC addresses:\n$(ip link show | awk '/link\/ether/ {print "MAC Address:", $2}')"
echo -e "🔹 Network information:\n$(ip addr show | awk '/inet / {print "Network:", $2}')"
echo "🔹 DNS: $(sudo cat /etc/resolv.conf | awk '/nameserver/ {print $2}')"
echo "🔹 OS Version: $(lsb_release -ds)"
echo "🔹 Kernel Version: $(uname -r)"
echo "🔹 CPU: $(lscpu | grep 'Model name' | awk -F ':' '{print $2}')"
echo "🔹 Memory: $(free -h | awk '/Mem/ {print $2}')"
echo "---------------------------------------------"

# Add Kubernetes APT repository
echo -e "\n📦 Adding Kubernetes APT repository..."
sudo mkdir -p -m 755 /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]]; then
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt update -qq

# Install Kubernetes components
echo -e "\n📥 Installing Kubernetes components (kubelet, kubeadm, kubectl)..."
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo -e "\n🔹 Kubelet Version: $(kubelet --version | awk '{print $2}')"
echo "🔹 Kubectl Version: $(kubectl version --client --output=yaml | grep gitVersion | awk '{print $2}')"
echo "🔹 Kubeadm Version: $(kubeadm version -o short)"
# echo "Kubeadm version: $(kubeadm version | grep -oP 'GitVersion:\s*"\K[^"]+')" # Alternative method
echo -e "\n✅ Kubernetes components installed successfully!"

# Load necessary kernel modules
echo -e "\n🛠️ Loading required kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf > /dev/null
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Apply sysctl settings for Kubernetes
echo -e "\n⚙️ Applying sysctl settings for Kubernetes networking..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system > /dev/null

# Verify applied settings
echo -e "\n✅ Verifying applied sysctl settings..."
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.ipv4.ip_forward

echo -e "\n🎉 Kubernetes Node Preparation Completed Successfully!"
echo "====================================="