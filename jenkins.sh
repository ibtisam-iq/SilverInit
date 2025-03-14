#!/bin/bash

# SilverInit - Jenkins Server Setup
# -------------------------------------------------
# This script installs Jenkins on Ubuntu or Linux Mint.

# Exit immediately if a command fails
set -e  

# Ensure the script is running on Ubuntu or Linux Mint
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" || "$ID" == "debian" ]]; then
        echo -e "\n✅ Detected supported OS: $NAME ($ID)"
    else
        echo -e "\n❌ This script is only for Ubuntu & its derivatives. Exiting...\n"
        exit 1
    fi
else
    echo -e "\n❌ Unable to determine OS type. Exiting...\n"
    exit 1
fi

# AWS Security Group Warning
echo -e "\n⚠️  If you're running this on an AWS EC2 instance, you must manually open port 8080 in the security group."

while true; do
    read -p "Have you already opened port 8080 in your AWS Security Group? (yes/no): " port_check
    port_check=$(echo "$port_check" | tr '[:upper:]' '[:lower:]')  # Convert input to lowercase

    if [[ "$port_check" == "yes" ]]; then
        break  # Proceed with the script
    elif [[ "$port_check" == "no" ]]; then
        echo -e "\n🔹 Follow these steps to allow external access to Jenkins on port 8080:\n"
        echo -e "1️⃣ Go to your AWS EC2 Dashboard."
        echo -e "2️⃣ Select your EC2 instance."
        echo -e "3️⃣ Scroll down to the 'Security' tab and click on your Security Group."
        echo -e "4️⃣ Click 'Edit Inbound Rules' → 'Add Rule'."
        echo -e "5️⃣ Set:"
        echo -e "   - Type: Custom TCP"
        echo -e "   - Protocol: TCP"
        echo -e "   - Port Range: 8080"
        echo -e "   - Source: 0.0.0.0/0 (or your specific IP for security)"
        echo -e "6️⃣ Click 'Save rules'.\n"
        read -p "🔄 Press Enter once you have opened port 8080..."
    else
        echo -e "\n❌ Invalid input! Please enter **yes** or **no**.\n"
    fi
done

# Install Jenkins
echo -e "\n🚀 Installing Jenkins..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key > /dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
echo -e "\n🔑 The server is updating its packages and installing Jenkins..."
sudo apt update -qq > /dev/null 2>&1
sudo apt install openjdk-17-jre-headless jenkins -y > /dev/null 2>&1

# Enable & Start Jenkins
sudo systemctl enable jenkins > /dev/null 2>&1
sudo systemctl restart jenkins > /dev/null 2>&1

# Check Jenkins Status
if systemctl is-active --quiet jenkins; then
    echo "✅ Jenkins is running."
else
    echo "❌ Jenkins is NOT running. Starting Jenkins..."
    sudo systemctl start jenkins
fi

# Display Jenkins Initial Admin Password
echo -e "\n🔑 Please use the following password to unlock Jenkins:"
echo -e "$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)\n"

# Show Jenkins Access URL
echo -e "\n✅ Jenkins is installed successfully! Access it via: http://$(hostname -I | awk '{print $1}'):8080\n"


