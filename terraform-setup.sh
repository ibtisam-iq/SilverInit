# ==================================================
# SilverInit - Terraform Setup
# --------------------------------------------------
# This script installs Terraform on Ubuntu or its derivatives.
# Author: Muhammad Ibtisam Iqbal
# License: MIT
# ==================================================

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR
REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

# ==================================================
# 🛠️ Preflight Check
# ==================================================
echo -e "\n\033[1;34m🚀 Running preflight.sh script to ensure that system meets the requirements to install Terraform...\033[0m"
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo -e "\n\033[1;31m❌ Failed to execute preflight.sh. Exiting...\033[0m"; exit 1; }
echo -e "\n\033[1;32m✅ System meets the requirements to install Terraform.\033[0m"

# ==================================================
# 🔍 Checking for Existing Installation
# ==================================================
if command -v terraform &> /dev/null; then
    echo -e "\n\033[1;32m✅ Terraform is already installed.\033[0m"
    echo -e "📌 Installed Version: \033[1;36m$(terraform --version | head -n1 | awk '{print $2}')\033[0m\n"
    exit 0
fi

# ==================================================
# 📦 Installing Dependencies
# ==================================================
echo -e "\n\033[1;34m🚀 Updating package list and checking required dependencies to install Terraform...\033[0m"
sudo apt update -qq && sudo apt install -yq software-properties-common lsb-release gnupg > /dev/null 2>&1

DEPS=("curl" "wget")
for pkg in "${DEPS[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
        echo -e "\033[1;33m🔹 Installing missing dependency: $pkg...\033[0m"
        sudo apt-get install -yq "$pkg" > /dev/null 2>&1
    else
        echo -e "\033[1;32m✅ $pkg is already installed.\033[0m"
    fi
done

# ==================================================
# 🔑 Adding HashiCorp Repository
# ==================================================
if wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; then
    echo -e "\n\033[1;32m✅ HashiCorp GPG key added successfully.\033[0m"
else
    echo -e "\n\033[1;31m❌ Failed to add HashiCorp GPG key. Exiting...\033[0m\n"
    exit 1
fi

if echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null; then
    echo -e "\033[1;32m✅ HashiCorp repository added successfully.\033[0m"
else
    echo -e "\n\033[1;31m❌ Failed to add HashiCorp repository. Exiting...\033[0m\n"
    exit 1
fi

# ==================================================
# 📥 Installing Terraform
# ==================================================
echo -e "\n\033[1;34m🚀 Installing Terraform...\033[0m\n"
if sudo apt update -qq && sudo apt install -y terraform > /dev/null 2>&1; then
    echo -e "\n\033[1;32m✅ Terraform installed successfully.\033[0m"
    echo -e "📌 Installed Version: \033[1;36m$(terraform --version | head -n1 | awk '{print $2}')\033[0m\n"
else
    echo -e "\n\033[1;31m❌ Terraform installation failed. Exiting...\033[0m\n"
    exit 1
fi

# ==================================================
# ℹ️ CLI Argument Handling (Future Support)
# ==================================================
echo -e "\n\033[1;33m⚠️  If you want CLI argument handling (e.g., -q for quiet mode, --no-update to skip updates), let me know, and I'll add it!\033[0m\n"
