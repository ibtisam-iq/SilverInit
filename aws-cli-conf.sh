#!/bin/bash

# SilverInit - AWS CLI Installation and Configuration Script
# -------------------------------------------------
# This script installs AWS CLI v2 on Linux and configures it with your AWS credentials.
# It also removes any existing AWS CLI v1 configuration files.

# Exit immediately if a command fails
set -e

REPO_URL="https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main"

echo -e "\n🚀 Running preflight.sh script to ensure that system meets the requirements to install AWS CLI v2..."
bash <(curl -sL "$REPO_URL/preflight.sh") || { echo "❌ Failed to execute preflight.sh. Exiting..."; exit 1; }
echo -e "\n✅ System meets the requirements to install AWS CLI v2."

# Check if AWS CLI is installed
if command -v aws &>/dev/null; then
    AWS_VERSION=$(aws --version 2>/dev/null | awk '{print $1}' | cut -d'/' -f2 | cut -d'.' -f1)
    
    if [[ "$AWS_VERSION" == "1" ]]; then
        echo -e "\n🔻 Uninstalling AWS CLI v1..."
        sudo apt remove -y awscli
        echo -e "✅ AWS CLI v1 is uninstalled successfully."
    elif [[ "$AWS_VERSION" == "2" ]]; then
        echo -e "\n✅ AWS CLI v2 is already installed. No action needed."
        exit 0  # Exit the script since v2 is already installed
    else
        echo -e "\n⚠️ Unknown AWS CLI version detected: $AWS_VERSION"
        exit 1  # Exit with an error code if the version is unrecognized
    fi
else
    echo -e "\n❌ AWS CLI v2 is not installed."
fi

# Remove AWS CLI v1 configuration files
if [[ -d "$HOME/.aws" ]]; then
    echo -e "\n🔻 Removing AWS CLI v1 configuration files..."
    rm -rf "$HOME/.aws"
    echo -e "\n✅ AWS CLI v1 configuration files are removed successfully."
fi

# Update system and install required dependencies
echo -e "\n🚀 Updating package list and checking required dependencies to install AWS CLI v2..."
sudo apt update -qq

DEPS=("unzip" "python3" "groff" "less")

for pkg in "${DEPS[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
        echo -e "\n🔹 Installing missing dependency: $pkg..."
        sudo apt-get install -yq "$pkg" > /dev/null 2>&1
    else
        echo -e "✅ $pkg is already installed."
    fi
done

# Install AWS CLI
echo -e "\n🚀 Installing AWS CLI v2..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt update -qq && sudo apt install -yq unzip python3 groff less libc6 > /dev/null 2>&1
unzip awscliv2.zip > /dev/null 2>&1
sudo ./aws/install
rm -rf aws awscliv2.zip aws
echo -e "\n✅ AWS CLI is installed successfully." 
echo -e "\n🔹 AWS CLI Version: $(aws --version | awk '{print $1}' | cut -d'/' -f2)"

# Function to configure AWS CLI
configure_aws_cli() {
    echo -e "\n🔧 Configuring AWS CLI...\n"

    # Ensure input works even in 'curl | bash' mode
    exec </dev/tty

    while true; do
        read -r -p "AWS Access Key ID: " AWS_ACCESS_KEY
        read -r -p "AWS Secret Access Key: " AWS_SECRET_KEY
        read -r -p "Default region name: " AWS_REGION
        read -r -p "Default output format [json/text/table]: " AWS_OUTPUT 

        # Configure AWS CLI with provided credentials
        aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
        aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
        aws configure set region "$AWS_REGION"
        aws configure set output "$AWS_OUTPUT"

        # Verify if setup was successful
        if aws sts get-caller-identity &>/dev/null; then
            echo -e "✅ AWS CLI is configured successfully.\n"
            return 0
        else
            echo -e "\n❌ AWS CLI setup failed. Please check your input and try again.\n"
        fi
    done
}

# Check if AWS credentials file exists
echo -e "\n🔧 Checking AWS CLI configuration..."

if [[ -f "$HOME/.aws/credentials" ]]; then
    echo -e "✅ AWS credentials file found. Extracting details...\n"

    AWS_ACCESS_KEY=$(awk '/aws_access_key_id/ {print $3}' "$HOME/.aws/credentials")
    AWS_SECRET_KEY=$(awk '/aws_secret_access_key/ {print $3}' "$HOME/.aws/credentials")
    AWS_REGION=$(awk '/region/ {print $3}' "$HOME/.aws/config")

    if [[ -n "$AWS_ACCESS_KEY" && -n "$AWS_SECRET_KEY" && -n "$AWS_REGION" ]]; then
        echo -e "🔹 Using existing credentials."
        aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
        aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
        aws configure set region "$AWS_REGION"

        # Verify existing credentials
        if aws sts get-caller-identity &>/dev/null; then
            echo -e "✅ AWS CLI is configured with existing credentials.\n"
            exit 0
        else
            echo -e "⚠️  Existing credentials are incorrect. Reconfiguring...\n"
            configure_aws_cli
        fi
    else
        echo -e "⚠️  Credentials file is incomplete. Prompting for new credentials...\n"
        configure_aws_cli
    fi
else
    echo -e "⚠️ No AWS credentials found. Prompting for setup...\n"
    configure_aws_cli
fi

# ==================================================
# 🎉 Setup Complete! Thank You! 🙌
# ==================================================
echo -e "\n\033[1;33m✨  Thank you for choosing SilverInit - Muhammad Ibtisam 🚀\033[0m\n"
echo -e "\033[1;32m💡 Automation is not about replacing humans; it's about freeing them to be more human—to create, innovate, and lead. \033[0m\n"