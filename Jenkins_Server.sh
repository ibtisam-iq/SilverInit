#!/bin/bash

# Exit immediately if a command fails
set -e

# Restart Jenkins after adding jenkins user to docker group
sudo usermod -aG docker jenkins
bash <(newgrp docker)
echo -e "\n🔄 Restarting Jenkins to apply changes..."

curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.60.0