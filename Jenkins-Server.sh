#!/bin/bash

# ╔══════════════════════════════════════════════════╗
# ║          SilverInit - Jenkins Server Setup       ║
# ║          (c) 2025 Muhammad Ibtisam Iqbal         ║
# ║          License: MIT                            ║
# ╚══════════════════════════════════════════════════╝
# 
# 📌 Description:
# This script automates the setup of a Jenkins server for managing resources.
# It executes a sequence of scripts to configure the OS, install required tools,
# and set up the Jenkins server.
#   - ✅ System preflight checks
#   - ✅ OS and system updates
#   - ✅ Jenkins installation and setup
#   - ✅ Docker installation and setup
#   - ✅ Kubernetes (kubectl & eksctl) installation
#   - ✅ Trivy security scanner setup
#
# 🚀 Usage:
#   curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/Jenkins-Server.sh | sudo bash
#
# 📜 License: MIT | 🌐 https://github.com/ibtisam-iq/SilverInit

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n\033[1;31m❌ Error occurred at line $LINENO. Exiting...\033[0m\n" && exit 1' ERR

# Define the repository URL
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# List of scripts to execute
SCRIPTS=(
    "preflight.sh"
    "sys-info-and-update.sh"
    "jenkins-setup.sh"
    "docker-setup.sh"
    "kubectl-and-eksctl.sh"
    "trivy-setup.sh"
)

# ==================================================
# 🚀 Executing Scripts
# ==================================================
for script in "${SCRIPTS[@]}"; do
    echo -e "\n\033[1;34m🚀 Running $script script...\033[0m"
    bash <(curl -fsSL "$REPO_URL/$script") || { echo -e "\n\033[1;31m❌ Failed to execute $script. Exiting...\033[0m\n"; exit 1; }
    echo -e "\033[1;32m✅ Successfully executed $script.\033[0m\n"
done

# ==================================================
# 🔄 Post Setup Tasks
# ==================================================
# Restart Jenkins after adding jenkins user to docker group
sudo usermod -aG docker jenkins
echo -e "\n\033[1;33m🔄 Restarting Jenkins to apply changes...\033[0m"
sudo systemctl restart jenkins

# Get the local machine's primary IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Get the public IP (if accessible)
PUBLIC_IP=$(curl -s ifconfig.me || echo "Not Available")

# Print both access URLs and let the user decide
echo -e "\n\033[1;36m🔗 Access Jenkins server using one of the following based on your network:\033[0m"
echo -e "\n - Local Network:  http://$LOCAL_IP:8080"
echo -e "\n - Public Network: http://$PUBLIC_IP:8080\n"

# Display Jenkins Initial Admin Password
echo -e "\n\033[1;32m🔑 Please use this password to unlock Jenkins: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)\033[0m\n"

echo -e "\033[1;36m🎉 Jenkins server setup completed. You can now access Jenkins using the provided URL.\033[0m\n"

# Display message to apply changes to groups
echo -e "\n\033[1;33m🔄 Jenkins user is added to docker group, please run this command for applying the changes: newgrp docker\033[0m\n"
