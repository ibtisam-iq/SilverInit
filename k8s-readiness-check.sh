#!/bin/bash

set -e  # Exit immediately if a command fails
set -o pipefail  # Ensure failures in piped commands are detected

# Function to handle script failures
trap 'echo -e "\n❌ Error occurred at line $LINENO. Exiting...\n" && exit 1' ERR

# Waiting for Cluster Readiness (10 min max)
echo -e "\n\033[1;33m⏳ Waiting up to 10 minutes for the control plane and pods to become ready...\033[0m"
TIMEOUT=600  # 10 minutes in seconds
INTERVAL=30  # Check every 30 seconds
elapsed=0

while [[ $elapsed -lt $TIMEOUT ]]; do
    NODES_READY=$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready ')
    PODS_READY=$(kubectl get pods -A --no-headers 2>/dev/null | awk '{print $4}' | grep -c 'Running')

    echo -e "\n\033[1;33m📊 Status: Nodes Ready: $NODES_READY | Pods Running: $PODS_READY (Elapsed: $elapsed sec)\033[0m"

    if [[ $NODES_READY -gt 0 && $PODS_READY -gt 0 ]]; then
        echo -e "\033[1;32m✅ Control plane and all pods are ready.\033[0m"
        break
    fi

    sleep $INTERVAL
    ((elapsed+=INTERVAL))
done

if [[ $elapsed -ge $TIMEOUT ]]; then
    echo -e "\n\033[1;31m❌ Timeout! Cluster not ready after 10 minutes. Exiting...\033[0m"
    exit 1
fi
