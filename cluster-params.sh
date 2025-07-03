#!/bin/bash
# cluster-params.sh

# 📡 Automatically detect Control Plane IP
CONTROL_PLANE_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')

# 🖥️ Get static hostname
NODE_NAME=$(hostnamectl --static)

# 📦 Pod CIDR (e.g., Flannel)
POD_CIDR="10.244.0.0/16"
