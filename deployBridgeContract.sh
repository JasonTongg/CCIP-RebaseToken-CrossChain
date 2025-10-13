#!/usr/bin/env bash
set -euo pipefail

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
else
  echo ".env file not found!"
  exit 1
fi

REQUIRED_VARS=(
  PRIVATE_KEY
  PUBLIC_KEY
  ARBITRUM_SEPOLIA_RPC_URL
  ARBITRUM_REBASE_TOKEN_ADDRESS
  ARBITRUM_LINK_ADDRESS
  ARBITRUM_ROUTER
  ARBITRUM_BRIDGE_CONTRACT
  BASE_CHAIN_SELECTOR
  SEPOLIA_CHAIN_SELECTOR
  OP_CHAIN_SELECTOR
  SONEIUM_CHAIN_SELECTOR
)
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "ERROR: $var is not set in .env"
    exit 1
  fi
done

echo ""
echo "Deploying BridgeTokens contract on Arbitrum..."
DEPLOY_OUTPUT=$(forge script ./script/BridgeDeploy.s.sol:BridgeDeploy \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast)

echo "$DEPLOY_OUTPUT"

echo ""
echo "Deploying BridgeTokens contract on Sepolia..."
DEPLOY_OUTPUT=$(forge script ./script/BridgeDeploy.s.sol:BridgeDeploy \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast)

echo "$DEPLOY_OUTPUT"

echo ""
echo "Deploying BridgeTokens contract on Base..."
DEPLOY_OUTPUT=$(forge script ./script/BridgeDeploy.s.sol:BridgeDeploy \
  --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast)

echo "$DEPLOY_OUTPUT"

echo ""
echo "Deploying BridgeTokens contract on OP..."
DEPLOY_OUTPUT=$(forge script ./script/BridgeDeploy.s.sol:BridgeDeploy \
  --rpc-url "${OP_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast)

echo "$DEPLOY_OUTPUT"

echo ""
echo "Deploying BridgeTokens contract on Unichain..."
DEPLOY_OUTPUT=$(forge script ./script/BridgeDeploy.s.sol:BridgeDeploy \
  --rpc-url "${UNI_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast)

echo "$DEPLOY_OUTPUT"

echo ""
echo "Deploying BridgeTokens contract on Soneium..."
DEPLOY_OUTPUT=$(forge script ./script/BridgeDeploy.s.sol:BridgeDeploy \
  --rpc-url "${SONEIUM_MINATO_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast)

echo "$DEPLOY_OUTPUT"
