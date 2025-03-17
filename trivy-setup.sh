#!/bin/bash

# SilverInit - Trivy Setup
# -------------------------------------------------
# This script installs Trivy on Ubuntu or its derivatives.


# Exit immediately if a command fails
set -e  

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running preflight.sh script to ensure that system meets the requirements to install Trivy..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }
echo -e "\n✅ System meets the requirements to install Trivy."

# Check if Trivy is already installed
if command -v trivy &> /dev/null; then
    echo -e "\n✅ Trivy is already installed. Version: $(trivy --version | head -n 1 | awk '{print $2}')\n"
    exit 0
fi

# Install Trivy securely
echo -e "\n🚀 Installing Trivy..."
if curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.60.0; then
    echo -e "\n✅ Trivy installation completed successfully."
    echo -e "\n🔹 Trivy version: $(trivy --version | head -n 1 | awk '{print $2}')" 
else
    echo -e "\n❌ Failed to install Trivy. Exiting..."
    exit 1
fi

# ==================================================
# 🎉 Setup Complete! Thank You! 🙌
# ==================================================
echo -e "\n\033[1;33m✨  Thank you for choosing SilverInit - Muhammad Ibtisam 🚀\033[0m\n"
echo -e "\033[1;32m💡 Automation is not about replacing humans; it's about freeing them to be more human—to create, innovate, and lead. \033[0m\n"