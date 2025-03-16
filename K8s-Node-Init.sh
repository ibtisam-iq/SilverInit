#!/bin/bash

# SilverInit - Get the Nodes Ready for Kubernetes Cluster
# -------------------------------------------------
# This script prepares nodes for a Kubernetes cluster by:
# - Disabling swap
# - Setting the hostname
# - Installing required dependencies
# - Configuring sysctl settings for Kubernetes networking
# - Adding the Kubernetes APT repository and installing kubeadm, kubelet, and kubectl.
# - Running containerd and configuring it for Kubernetes

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# Ensure the script is running on Ubuntu or Linux Mint
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "linuxmint" ]]; then
        echo -e "\n❌ Unsupported OS: $NAME ($ID). This script is only for Ubuntu/Linux Mint. Exiting...\n"
        exit 1
    fi
    echo -e "\n✅ Detected OS: $NAME ($ID)\n"
else
    echo -e "\n❌ Unable to determine OS type. Exiting...\n"
    exit 1
fi

# Ensure 64-bit architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "amd64" ]]; then # FIX: Use `&&` instead of `||`
    echo -e "\n❌ Unsupported architecture: $ARCH. This script supports only x86_64 (amd64). Exiting...\n"
    exit 1
fi
echo -e "\n✅ Architecture supported: $ARCH\n"

echo -e "\n🚀 Starting Kubernetes Node Preparation...\n"

# Update system and install necessary dependencies
echo -e "\n🔄 Updating package lists and installing dependencies..."
sudo apt update -qq && sudo apt install -yq net-tools apt-transport-https ca-certificates curl gpg > /dev/null 2>&1

# Disable swap permanently
echo -e "\n🔧 Disabling swap...\n"
sudo swapoff -a
sudo sed -i '/\s\+swap\s\+/d' /etc/fstab

# Prompt user for a hostname (leave empty to keep the current one)
read -p "🔹 Please enter hostname for this node (leave empty to keep current): " HOSTNAME < /dev/tty

# Set hostname if provided

if [[ -n "$HOSTNAME" ]]; then
    echo "\n🖥️ Setting hostname to: $HOSTNAME"
    sudo hostnamectl set-hostname "$HOSTNAME" # Requires sudo privileges
    echo "\nℹ️ Hostname changed. Please reconnect using the new hostname."
#   exit 0
else
    echo "\nℹ️ Keeping the existing hostname: $(hostname)"
fi

# Display system information before Kubernetes setup
echo -e "\n📊 System Information Before Kubernetes Setup:"
echo "---------------------------------------------"
echo "🔹 Hostname: $(sudo hostnamectl --static)"
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
sudo apt-get install -yq kubelet kubeadm kubectl > /dev/null 2>&1
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

echo -e "\n🎉 Kernal modules are loaded, and sysctl settings are applied successfully!"

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running containerd-setup.sh script to configure containerd..."
bash <(curl -sL "$REPO_URL/containerd-setup.sh") || { echo "❌ Failed to execute containerd-setup.sh. Exiting..."; exit 1; }

echo -e "\n✅ All scripts executed successfully."

echo -e "\n✅ This node is ready to join the Kubernetes cluster either as worker node or control plane." 
echo -e "\n🎉 Happy Kuberneting! 🚀"
