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
# 6. trivy-setup.sh

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
    "trivy-setup.sh"
)

for script in "${SCRIPTS[@]}"; do
    echo -e "\n🚀 Running $script script..."
    bash <(curl -fsSL "$REPO_URL/$script") || { echo -e "\n❌ Failed to execute $script. Exiting...\n"; exit 1; }
done

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
echo -e "\n🔑 Please use this password to unlock Jenkins: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)\n"


echo -e "🎉 Jenkins server setup completed. You can now access Jenkins using the provided URL.\n"

# Display message to apply changes to groups
echo -e "\n🔄 Jenkins user is added to docker group, please run this command for applying the changes: newgrp docker\n"

