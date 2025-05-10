#!/usr/bin/env bash

set -euo pipefail

echo "⚠️  This will completely remove Aztec-related data, Docker containers/images, and environment files."
read -p "Are you sure you want to continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

echo "Stopping and removing Aztec-related Docker containers and images..."
docker ps -a --filter ancestor=aztecprotocol/aztec --format "{{.ID}}" | xargs -r docker stop
docker ps -a --filter ancestor=aztecprotocol/aztec --format "{{.ID}}" | xargs -r docker rm
docker images "aztecprotocol/aztec" --format "{{.ID}}" | xargs -r docker rmi -f

echo "Removing Docker volumes..."
docker volume ls --format "{{.Name}}" | grep aztec | xargs -r docker volume rm

echo "Removing Aztec data directories and config files..."
rm -rf "$HOME/.aztec"
rm -rf "$HOME/.aztec/alpha-testnet"
rm -f "$HOME/manage_node.sh"
rm -f .env
rm -rf ~/aztec-node 2>/dev/null || true

echo "✅ Everything related to Aztec validator node has been deleted."
