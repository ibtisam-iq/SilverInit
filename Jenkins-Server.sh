#!/bin/bash
# SilverInit - Jenkins Server Setup
# -------------------------------------------------
# This script automates the setup of a Jenkins server for managing the resources.
# It executes a sequence of scripts to configure the OS, install required tools,
# and set up the Jenkins server.

# The following scripts are executed in sequence:
# 1. preflight.sh
# 2. sys-info-and-update.sh
# 3. jenkins-setup.sh
# 4. docker-setup.sh
# 5. kubectl-and-eksctl.sh
# 6. Trivy installation

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# Define the repository URL
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# Execute required scripts in sequence
SCRIPTS=(
    "preflight.sh"
    "sys-info-and-update.sh"
    "jenkins-setup.sh"
    "docker-setup.sh"
    "kubectl-and-eksctl.sh"
)

for script in "${SCRIPTS[@]}"; do
    echo -e "\n🚀 Running $script script..."
    bash <(curl -fsSL "$REPO_URL/$script") || { echo -e "\n❌ Failed to execute $script. Exiting...\n"; exit 1; }
done

# Install Trivy securely
echo -e "\n🚀 Installing Trivy..."
if curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.60.0; then
    echo -e "\n✅ Trivy installation completed successfully."
    trivy --version | head -n 1 | awk '{print $2}' || echo "⚠️ Trivy installed, but version check failed."
else
    echo -e "\n❌ Failed to install Trivy. Exiting..."
    exit 1
fi

echo -e "\n✅ All scripts executed successfully.\n"


# Restart Jenkins after adding jenkins user to docker group
sudo usermod -aG docker jenkins
echo -e "\n🔄 Restarting Jenkins to apply changes..."
sudo systemctl restart jenkins

# Get the local machine's primary IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Get the public IP (if accessible)
PUBLIC_IP=$(curl -s ifconfig.me || echo "Not Available")

# Print both access URLs and let the user decide
echo -e "\n🔗 Access Jenkins server using one of the following based on your network:"
echo -e "\n - Local Network:  http://$LOCAL_IP:8080"
echo -e "\n - Public Network: http://$PUBLIC_IP:8080\n"


## Display Jenkins Initial Admin Password
echo -e "\n🔑 Please use the following password to unlock Jenkins: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)\n"