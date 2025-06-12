#!/bin/bash
set -euo pipefail

# Colors
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
YELLOW=$'\e[1;33m'
RESET=$'\e[0m'

# Load env variables
ENV_FILE="$HOME/aztec-validator-node/.env"
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
else
  echo -e "${RED}⚠️  .env file not found at $ENV_FILE. Run setup first.${RESET}"
  exit 1
fi

: "${RPC_URL:?Missing RPC_URL in .env}"
: "${RPC_BEACON_URL:?Missing RPC_BEACON_URL in .env}"
: "${AZTEC_PORT:=8080}"

echo -e "${YELLOW}🩺 AZTEC VALIDATOR HEALTH CHECK${RESET}"
echo

# 1. Geth (Execution) sync status
echo -n "🔧 Geth Sync Status: "
if curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' "$RPC_URL" \
  | grep -q "false"; then
  echo -e "${GREEN}✅ Synced${RESET}"
else
  echo -e "${RED}❌ Syncing or Unreachable${RESET}"
fi

# 2. Beacon sync check
echo -n "🛰  Beacon Sync Status: "
if curl -s "$RPC_BEACON_URL/eth/v1/node/syncing" | jq -e '.data.head_slot' > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Reachable${RESET}"
else
  echo -e "${RED}❌ Unreachable or Sync Error${RESET}"
fi

# 3. Aztec L2 Proven Block check
echo -n "🧱 Aztec L2 Proven Block: "
L2_RAW=$(curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":1}' \
  "http://127.0.0.1:$AZTEC_PORT")

L2_BLOCK=$(echo "$L2_RAW" | jq -r '.result.proven.number' 2>/dev/null || echo "")

if [[ "$L2_BLOCK" =~ ^[0-9]+$ ]]; then
  echo -e "${GREEN}✅ Block $L2_BLOCK${RESET}"
else
  echo -e "${RED}❌ Could not get block number${RESET}"
fi
