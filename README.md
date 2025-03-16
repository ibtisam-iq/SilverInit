# SilverInit

## Kubernetes Node Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/K8s-Node-Init.sh | sudo bash
```

## Kubernetes First Control Plane Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/K8s-Control-Plane-Init.sh | sudo bash
```
---

## Jumpbox Server Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/Jumpbox.sh | sudo bash
```

## Jenkins Server Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/Jenkins-Server.sh | bash
```

### Jenkins

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/jenkins-setup.sh | bash
```

### Docker

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/docker-setup.sh | bash
```

### Ansible

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/ansible-setup.sh | bash
```

### Terraform

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/terraform-setup.sh | bash
```

### AWS CLI

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/aws-cli-conf.sh | bash
```

### Kubectl & Eksctl

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/kubectl-and-eksctl.sh | bash
```

### SonarQube Container

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/sonarqube-cont.sh | bash
```

### Nexus Container

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/nexus-cont.sh | bash
```

### Containerd

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/containerd-setup.sh | bash
```

### Helm

```bash
curl -sL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
echo -e "\n🔹 Helm Version: $(helm version)\n"
```

### Trivy

``` bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.60.0
echo -e "\n🔹 Trivy Version: $(trivy --version | head -n 1 | awk '{print $2}')\n"
```

### Get System Information

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/sys-info-and-update.sh | bash
```