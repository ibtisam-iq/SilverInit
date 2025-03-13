#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update and install necessary dependencies
echo "Updating system and installing dependencies..."
sudo apt update -qq && sudo apt install -yq net-tools apt-transport-https ca-certificates curl gpg

# Disable swap permanently
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/\s\+swap\s\+/d' /etc/fstab


# Prompt user for a hostname (leave empty to keep the current one)
read -p "Enter hostname for the control plane (leave empty to keep current): " HOSTNAME

# Set hostname if provided

if [[ -n "$HOSTNAME" ]]; then
    echo "Setting hostname to $HOSTNAME"
    if command -v hostnamectl &>/dev/null; then
        sudo hostnamectl set-hostname "$HOSTNAME"
    else
        echo "Warning: hostnamectl not found, skipping hostname update."
    fi
else
    echo "Keeping the existing hostname."
fi


# Display system information before Kubernetes setup

echo "====================================="
echo "System Information Before Kubernetes Setup"
echo "====================================="

echo "Hostname: $(sudo hostnamectl --static)"
if [[ -r /sys/class/dmi/id/product_uuid ]]; then
    echo "Machine UUID: $(cat /sys/class/dmi/id/product_uuid)"
else
    echo "Machine UUID: Access Denied (Run script with sudo)"
fi
echo "Private IP: $(sudo hostname -I | awk '{print $1}')"
echo "Public IP: $(curl -s ifconfig.me || curl -s https://ipinfo.io/ip || echo "Failed to retrieve IP")"
echo -e "MAC addresses:\n$(ip link show | awk '/link\/ether/ {print "MAC Address:", $2}')"
echo -e "Network information:\n$(ip addr show | awk '/inet / {print "Network:", $2}')"
echo "DNS information: $(sudo cat /etc/resolv.conf | awk '/nameserver/ {print $2}')"
echo "Kernel version: $(sudo uname -r)"
echo "OS version: $(lsb_release -ds)"
echo "CPU information: $(lscpu | grep 'Model name' | awk -F ':' '{print $2}')"
echo "Memory information: $(free -h | awk '/Mem/ {print $2}')"

echo "====================================="

# Add Kubernetes APT repository
echo "Adding Kubernetes repository..."
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update -qq

# Install Kubernetes components
echo "Installing Kubernetes components (kubelet, kubeadm, kubectl)..."
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
echo "Kubelet version: $(kubelet --version | awk '{print $2}')"
echo "Kubectl version: $(kubectl version --client --short | awk '{print $3}')"
echo "Kubeadm version: $(kubeadm version --short | awk '{print $2}')"
echo "Kubernetes components installed successfully!"

echo "====================================="

# Load necessary kernel modules
echo "Loading required kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl settings
echo "Applying sysctl settings for Kubernetes..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system > /dev/null

# Verify applied settings
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.ipv4.ip_forward

echo "Kernel modules and sysctl settings applied successfully!"

echo "====================================="