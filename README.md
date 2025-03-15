# SilverInit

## Kubernetes Node Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/K8s-Node-Init.sh | bash
```

## Kubernetes First Control Plane Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/K8s-Control-Plane-Init.sh | bash
```


## Helm

```bash
curl -sL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
echo -e "\n🔹 Helm Version: $(helm version)\n"
```

## Trivy

``` bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.60.0
echo -e "\n🔹 Trivy Version: $(trivy --version | head -n 1 | awk '{print $2}')\n"
```