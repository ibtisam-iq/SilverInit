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

# Check if Jenkins is already installed
if command -v jenkins &> /dev/null; then
    echo -e "\n✅ Jenkins is already installed.\n"
    echo -e "\n📌 Installed Jenkins Version: $(jenkins --version)\n"
    exit 0
fi

# AWS Security Group Warning
echo -e "\n⚠️  If you're running this on an AWS EC2 instance, ensure port 8080 is open in the security group."

while true; do
    read -r -p "Have you opened port 8080 in your AWS Security Group? (yes/no): " port_check
    port_check=$(echo "$port_check" | tr '[:upper:]' '[:lower:]')  # Convert input to lowercase

    if [[ "$port_check" == "yes" ]]; then
        echo -e "\n✅ Port 8080 is open. Proceeding...\n"
        break  # Continue script execution
    elif [[ "$port_check" == "no" ]]; then
        echo -e "\n🔹 Follow these steps to allow external access to Jenkins on port 8080:\n"
        echo -e "1️⃣ Open the AWS EC2 Dashboard."
        echo -e "2️⃣ Select your EC2 instance."
        echo -e "3️⃣ Go to the 'Security' tab and click your Security Group."
        echo -e "4️⃣ Click 'Edit Inbound Rules' → 'Add Rule'."
        echo -e "5️⃣ Set:"
        echo -e "   - **Type**: Custom TCP"
        echo -e "   - **Protocol**: TCP"
        echo -e "   - **Port Range**: 8080"
        echo -e "   - **Source**: 0.0.0.0/0 *(or your IP for security)*"
        echo -e "6️⃣ Click 'Save rules'.\n"
        read -r -p "🔄 Press Enter after opening port 8080..."
    else
        echo -e "\n❌ Invalid input! Please enter **yes** or **no**.\n"
    fi
done


# Update system and install required dependencies
echo -e "\n🚀 Updating package list and checking required dependencies..."
sudo apt update -qq

# Check if Java is installed
if java -version &>/dev/null; then
    echo -e "✅ Java is already installed."
else
    echo -e "🔹 Installing missing dependency: OpenJDK 17..."
    sudo apt-get install -yq openjdk-17-jdk-headless > /dev/null 2>&1
fi

# Install Jenkins
echo -e "\n🚀 Installing Jenkins..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key > /dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
echo -e "\n🔑 The server is updating its packages and installing Jenkins..."
sudo apt update -qq > /dev/null 2>&1
sudo apt install jenkins -y > /dev/null 2>&1

# Enable & Start Jenkins
sudo systemctl enable jenkins > /dev/null 2>&1
sudo systemctl restart jenkins > /dev/null 2>&1

# Check Jenkins Status
if systemctl is-active --quiet jenkins; then
    echo -e "\n✅ Jenkins is running.\n"
else
    echo "❌ Jenkins is NOT running. Starting Jenkins..."
    sudo systemctl start jenkins
fi

# Display Jenkins Version

echo -e "\n📌 Installed Jenkins Version: $(jenkins --version)\n"
# echo -e "\n📌 Installed Jenkins Version: $(sudo dpkg -l | grep jenkins | awk '{print $3}')\n"

# Get the local machine's primary IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Get the public IP (if accessible)
PUBLIC_IP=$(curl -s ifconfig.me || echo "Not Available")

# Print both access URLs and let the user decide
echo -e "\n🔗 Access Jenkins server using one of the following based on your network:"
echo -e "\n - Local Network:  http://$LOCAL_IP:$USER_PORT"
echo -e "\n - Public Network: http://$PUBLIC_IP:$USER_PORT\n"


## Display Jenkins Initial Admin Password
echo -e "\n🔑 Please use the following password to unlock Jenkins: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)\n"


