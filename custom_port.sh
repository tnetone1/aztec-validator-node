#!/usr/bin/env bash
# Aztec Alpha-Testnet Validator Manager (Final Production Version)

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
AZTEC_PORT="$AZTEC_PORT"
EOF
  chmod 600 "$ENV_FILE"
}

install_dependencies() {
  echo "Installing dependencies..."
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop \
    nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip ca-certificates gnupg

  echo "Installing Docker..."
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
  sudo systemctl enable docker && sudo systemctl restart docker
}

stop_node() {
  pkill -f "aztec start" || true
  docker ps -q --filter ancestor=aztecprotocol/aztec | xargs -r docker stop | xargs -r docker rm
}

start_node() {
  load_env
  sudo ufw allow "$AZTEC_PORT"/tcp || true

  echo "Starting Aztec node..."
  "$HOME/.aztec/bin/aztec" start --node --archiver --sequencer \
    --network alpha-testnet \
    --l1-rpc-urls "$RPC_URL" \
    --l1-consensus-host-urls "$RPC_BEACON_URL" \
    --sequencer.validatorPrivateKey "$PRIVATE_KEY" \
    --sequencer.coinbase "$PUBLIC_KEY" \
    --p2p.p2pIp "$P2P_IP" \
    --port "$AZTEC_PORT"
}

restart_node() {
  stop_node
  start_node
}

setup() {
  install_dependencies

  echo "Installing Aztec CLI..."
  (
    curl -s https://install.aztec.network | bash
  )
  export PATH="$HOME/.aztec/bin:$PATH"

  echo "Setting Aztec version to latest..."
  "$HOME/.aztec/bin/aztec-up" latest

  read -rp "Sepolia RPC URL: " RPC_URL
  read -rp "Sepolia Beacon URL: " RPC_BEACON_URL
  read -rp "Validator PUBLIC key: " PUBLIC_KEY
  read -rsp "Validator PRIVATE key: " PRIVATE_KEY; echo
  read -rp "Custom Aztec RPC Port (default 8080): " AZTEC_PORT
  AZTEC_PORT=${AZTEC_PORT:-8080}
  P2P_IP=$(curl -sS ipv4.icanhazip.com || read -rp "Public IP: " P2P_IP)

  save_env
  start_node
}

get_apprentice() {
  load_env
  block=$(curl -s -X POST -H 'Content-Type: application/json' \
    -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":1}' \
    http://localhost:"$AZTEC_PORT" | jq -r .result.proven.number)
  proof=$(curl -s -X POST -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"node_getArchiveSiblingPath\",\"params\":[\"$block\",\"$block\"],\"id\":1}" \
    http://localhost:"$AZTEC_PORT" | jq -r .result)
  echo -e "Address:      ${YELLOW}$PUBLIC_KEY${RESET}"
  echo -e "Block-Number: ${YELLOW}$block${RESET}"
  echo -e "Proof:        ${YELLOW}$proof${RESET}"
}

register_validator() {
  load_env
  "$HOME/.aztec/bin/aztec" add-l1-validator \
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
  read -rp "New RPC Port: " AZTEC_PORT
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
echo -e "${YELLOW}              TG>>@brock0021 ${RESET}"
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
