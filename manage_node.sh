#!/usr/bin/env bash
# manage_node.sh — All-in-one Aztec Alpha-Testnet Validator Manager
# by TG - @Brock0021

set -euo pipefail

# Colors
RED=$'\e[0;31m'; GREEN=$'\e[0;32m'; YELLOW=$'\e[1;33m'; CYAN=$'\e[0;36m'; BOLD=$'\e[1m'; RESET=$'\e[0m'

ENV_FILE=".env"
DATA_DIR="$HOME/.aztec/alpha-testnet/data"

load_env() { [ -f "$ENV_FILE" ] && . "$ENV_FILE"; }

save_env() {
  cat > "$ENV_FILE" <<EOF
RPC_URL="$RPC_URL"
RPC_BEACON_URL="$RPC_BEACON_URL"
PUBLIC_KEY="$PUBLIC_KEY"
PRIVATE_KEY="$PRIVATE_KEY"
P2P_IP="$P2P_IP"
EOF
  chmod 600 "$ENV_FILE"
}

install_dependencies() {
  echo "Checking for package manager locks and terminating any blocking processes..."
  # Detect and kill processes holding apt/dpkg locks
  for lock in /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock; do
    if sudo lsof "$lock" >/dev/null 2>&1; then
      pids=$(sudo lsof -t "$lock")
      echo -e "${YELLOW}Killing processes holding $lock: $pids${RESET}"
      sudo kill -9 $pids || true
    fi
  done

  echo "Updating package lists and upgrading existing packages..."
  sudo apt-get update && sudo apt-get upgrade -y
  echo "Installing core dependencies..."
  sudo apt install -y \
    curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop \
    nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip

  # Clean up old Docker packages if present
  echo "Removing conflicting Docker packages if any..."
  for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove -y "$pkg" || true
  done

  echo "Setting up Docker repository and installing Docker engine..."
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update && sudo apt-get install -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable docker.service || true
  sudo systemctl restart docker.service || true
}

stop_node() {
  pkill -f "aztec start" || true
  docker ps -q --filter ancestor=aztecprotocol/aztec | xargs -r docker stop | xargs -r docker rm
}

start_node() {
  load_env
  exec aztec start --node --archiver --sequencer \
    --network alpha-testnet \
    --l1-rpc-urls "$RPC_URL" \
    --l1-consensus-host-urls "$RPC_BEACON_URL" \
    --sequencer.validatorPrivateKey "$PRIVATE_KEY" \
    --sequencer.coinbase "$PUBLIC_KEY" \
    --p2p.p2pIp "$P2P_IP"
}

restart_node() {
  stop_node
  start_node
}

setup() {
  install_dependencies
  if ! command -v aztec &>/dev/null; then
    curl -sSf https://install.aztec.network | bash
    export PATH="$HOME/.aztec/bin:$PATH"
  fi
  aztec-up alpha-testnet

  read -rp "Sepolia RPC URL: " RPC_URL
  read -rp "Sepolia Beacon URL: " RPC_BEACON_URL
  read -rp "Validator PUBLIC key: " PUBLIC_KEY
  read -rsp "Validator PRIVATE key: " PRIVATE_KEY; echo
  P2P_IP=$(curl -sS ipv4.icanhazip.com || read -rp "Public IP: " P2P_IP)

  save_env
  start_node
}

get_apprentice() {
  load_env
  block=$(curl -s -X POST -H 'Content-Type: application/json' \
    -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":1}' \
    http://localhost:8080 | jq -r .result.proven.number)
  proof=$(curl -s -X POST -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"node_getArchiveSiblingPath\",\"params\":[\"$block\",\"$block\"],\"id\":1}" \
    http://localhost:8080 | jq -r .result)
  echo -e "Address:      ${YELLOW}$PUBLIC_KEY${RESET}"
  echo -e "Block-Number: ${YELLOW}$block${RESET}"
  echo -e "Proof:        ${YELLOW}$proof${RESET}"
}

register_validator() {
  load_env
  exec aztec add-l1-validator \
    --l1-rpc-urls "$RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --attester "$PUBLIC_KEY" \
    --proposer-eoa "$PUBLIC_KEY" \
    --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
    --l1-chain-id 11155111
}

change_rpc() {
  load_env
  read -rp "New RPC URL: " RPC_URL
  read -rp "New Beacon URL: " RPC_BEACON_URL
  save_env
  restart_node
}

wipe_data() {
  load_env
  stop_node
  rm -rf "$DATA_DIR"
  start_node
}

full_clean() {
  stop_node
  rm -rf "$HOME/.aztec" "$ENV_FILE"
}

reinstall_node() {
  stop_node
  full_clean
  setup
}

echo -e "${CYAN}${BOLD}Aztec Validator Manager${RESET}"
echo -e "${YELLOW}              by Brock0021${RESET}"
echo "1) Setup Node Validator"
echo "2) Get Role Apprentice"
echo "3) Register Validator"
echo "4) Stop Node"
echo "5) Restart Node"
echo "6) Change RPC"
echo "7) Delete Node Data"
echo "8) Full Clean"
echo "9) Reinstall Node"
echo "x) Exit"
read -rp "Select: " choice

case "$choice" in
  1) setup ;;
  2) get_apprentice ;;
  3) register_validator ;;
  4) stop_node ;;
  5) restart_node ;;
  6) change_rpc ;;
  7) wipe_data ;;
  8) full_clean ;;
  9) reinstall_node ;;
  x|X) exit 0 ;;
  *) exit 1 ;;
esac
