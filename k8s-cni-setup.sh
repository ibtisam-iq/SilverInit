#!/bin/bash

# ───── OPTIONAL CLEAR SCREEN ─────
if [[ "$1" == "--clear" ]]; then
  clear
fi

# ╔═══════════════════════════════════╗
# │ SilverInit – CNI Network Utility  │
# ╚═══════════════════════════════════╝

# ───── COLORS ─────
YELLOW="\e[93m"
CYAN="\e[96m"
GREEN="\e[92m"
RED="\e[91m"
BOLD="\e[1m"
RESET="\e[0m"

# ───── TRAP FOR CTRL+C ─────
trap 'echo -e "\n${RED}❌ Script interrupted. Exiting...${RESET}"; exit 1' INT

# ───── CLEANUP OLD CNI RESIDUES ─────
echo -e "${CYAN}🧹 Removing previous CNI residues...${RESET}"

kubectl delete ns kube-flannel --force > /dev/null 2>&1

kubectl delete -n kube-system \
  serviceaccount/weave-net \
  role.rbac.authorization.k8s.io/weave-net \
  rolebinding.rbac.authorization.k8s.io/weave-net \
  daemonset.apps/weave-net > /dev/null 2>&1

kubectl delete clusterrole.rbac.authorization.k8s.io/weave-net \
  clusterrolebinding.rbac.authorization.k8s.io/weave-net > /dev/null 2>&1

sudo rm -rf /etc/cni/net.d/*

if systemctl is-active --quiet kubelet; then
  sudo systemctl stop kubelet
fi

PATTERNS=("flannel*" "cni0" "weave" "datapath" "vxlan*" "veth*")

for pattern in "${PATTERNS[@]}"; do
  regex="^${pattern//\*/.*}$"
  for iface in $(ip -o link show | awk -F': ' '{print $2}' | cut -d'@' -f1 | grep -E "$regex"); do
    echo -e "${YELLOW}Bringing down interface: $iface${RESET}"
    sudo ip link set "$iface" down > /dev/null 2>&1 || echo -e "${RED}⚠️ Could not bring down $iface${RESET}"

    echo -e "${YELLOW}Deleting interface: $iface${RESET}"
    sudo ip link delete "$iface" > /dev/null 2>&1 || {
      echo -e "${YELLOW}⚠️ $iface could not be deleted immediately. Retrying after 10s...${RESET}"
      sleep 10
      sudo ip link delete "$iface" > /dev/null 2>&1 || echo -e "${RED}❌ Failed to delete $iface after retry.${RESET}"
    }
  done
done

for ns in $(ip netns list | awk '{print $1}'); do
  echo -e "${YELLOW}🧹 Deleting namespace: $ns${RESET}"
  sudo ip netns delete "$ns" > /dev/null 2>&1 || echo -e "${RED}❌ Failed to delete $ns${RESET}"
done

if ip route | grep -q cni0; then
  sudo ip route flush table main
  sudo ip route flush cache
fi

sudo systemctl restart kubelet containerd

# ───── HEADER ─────
function print_header() {
  echo -e "${BOLD}${CYAN}SilverInit – CNI Network Setup Utility${RESET}"
  echo
  echo -e "${CYAN}Author   : Muhammad Ibtisam Iqbal"
  echo -e "Version  : v1.1"
  echo -e "Repo     : https://github.com/ibtisam-iq/SilverInit"
  echo -e "License  : MIT${RESET}\n"
}

# ───── CNI OPTIONS ─────
function print_cni_menu() {
  echo -e "${GREEN}🌐 Proceeding with Post-Initialization Steps...${RESET}"
  echo -e "${GREEN}→ CNI Network Setup and Cluster Verification${RESET}\n"
  echo -e "${CYAN}📡 Select a CNI plugin to install:${RESET}\n"
  echo " 1 Calico  - Best for advanced policy and large-scale clusters"
  echo " 2 Flannel - Lightweight and simple (default for many demos)"
  echo " 3 Weave   - Secure encryption, great for small clusters"
  echo
}

# ───── CNI INSTALL ─────
function install_cni() {
  local name="$1"
  local url="$2"

  echo -e "${GREEN}🔌 Installing ${BOLD}$name${RESET}${GREEN} CNI...${RESET}"
  echo

  if curl -sL "$url" | bash; then
    echo -e "${GREEN}✅ $name CNI installed successfully. Verifying cluster in 60s...${RESET}"
  else
    echo -e "${RED}❌ Failed to install $name. Check your internet or script URL.${RESET}"
    exit 1
  fi
}

# ───── CLUSTER CHECK ─────
function verify_cluster() {
  echo -e "\n⏳ Waiting 60 seconds for CNI to stabilize..."
  sleep 60
  echo -e "\n🔍 ${CYAN}Cluster Status:${RESET}\n"
  kubectl get nodes -o wide || echo -e "${RED}❌ Failed to get node status.${RESET}"
  echo
  kubectl get pods -A || echo -e "${RED}❌ Failed to get pod status.${RESET}"
  echo
}

# ───── MAIN FLOW ─────
function main() {
  print_header
  print_cni_menu

  read -p "Enter your choice [1-3]: " choice < /dev/tty
  echo
  case "$choice" in
    1|"") install_cni "Calico"  "https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/calico-setup.sh" ;;
    2)     install_cni "Flannel" "https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/flannel-setup.sh" ;;
    3)     install_cni "Weave"   "https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/weave-setup.sh" ;;
    *)
      echo -e "${RED}⚠️ Invalid input. Defaulting to Calico.${RESET}"
      install_cni "Calico"  "https://raw.githubusercontent.com/ibtisam-iq/SilverInit/main/calico-setup.sh"
      ;;
  esac

  verify_cluster
}

main
