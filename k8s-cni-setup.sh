#!/bin/bash

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

# ───── HEADER ─────
function print_header() {
  echo -e "${BOLD}${CYAN}SilverInit – CNI Network Setup Utility${RESET}"
  echo
  echo -e "${CYAN}Author   : Muhammad Ibtisam Iqbal"
  echo -e "Version  : v1.0"
  echo -e "Repo     : https://github.com/ibtisam-iq/SilverInit"
  echo -e "License  : MIT${RESET}\n"
}

# ───── CNI OPTIONS ─────
function print_cni_menu() {
  echo -e "${GREEN}🌐 Proceeding with Post-Initialization Steps...${RESET}"
  echo -e "${GREEN}→ CNI Network Setup and Cluster Verification${RESET}\n"
  echo -e "${CYAN}📡 Select a CNI plugin to install:${RESET}"
  sudo rm -rf /etc/cni/net.d/
  echo
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
    echo -e "${GREEN}✅ $name CNI installed successfully.${RESET}"
  else
    echo -e "${RED}❌ Failed to install $name. Check your internet or script URL.${RESET}"
    exit 1
  fi
}

# ───── CLUSTER CHECK ─────
function verify_cluster() {
  echo -e "\n⏳ Waiting 60 seconds for CNI to stabilize..."
  sleep 60
  echo -e "\n🔍 ${CYAN}Cluster Status:${RESET}"
  echo
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
