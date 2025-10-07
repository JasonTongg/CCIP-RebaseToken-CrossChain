#!/bin/bash
set -euo pipefail
# bridgeEthToArb.sh — bridge SEPOLIA -> ARBITRUM

# Load env
if [[ -f .env ]]; then
  sed -i 's/\r$//' .env
  # shellcheck disable=SC1090
  source .env
else
  echo ".env not found in $(pwd). Create it and export required variables."
  exit 1
fi

# --- Helper: require env var ---
require() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "ERROR: required env var $name is not set"
    exit 1
  fi
}

# Required environment variables
require ACCOUNT_NAME
require SEPOLIA_RPC_URL
require ARBITRUM_SEPOLIA_RPC_URL
require SEPOLIA_REBASE_TOKEN_ADDRESS
require SEPOLIA_POOL_ADDRESS
require ARBITRUM_POOL_ADDRESS
require ARBITRUM_REBASE_TOKEN_ADDRESS
require SEPOLIA_LINK_ADDRESS
require SEPOLIA_ROUTER
require ARBITRUM_SEPOLIA_CHAIN_SELECTOR
require SEPOLIA_CHAIN_SELECTOR
require AMOUNT

WALLET_ADDR=$(cast wallet address --account "${ACCOUNT_NAME}")
echo "Using account: ${ACCOUNT_NAME} -> ${WALLET_ADDR}"

# --- Deploy Vault on Sepolia if not exists ---
if [[ -z "${SEPOLIA_VAULT_ADDRESS:-}" ]]; then
  echo "SEPOLIA_VAULT_ADDRESS not provided — deploying Vault on Sepolia..."
  DEPLOY_OUTPUT=$(forge create ./src/Vault.sol:Vault \
    --rpc-url "${SEPOLIA_RPC_URL}" \
    --account "${ACCOUNT_NAME}" \
    --constructor-args "${SEPOLIA_REBASE_TOKEN_ADDRESS}" \
    --broadcast 2>&1)

  echo "${DEPLOY_OUTPUT}" | sed -n '1,200p'
  SEPOLIA_VAULT_ADDRESS=$(echo "${DEPLOY_OUTPUT}" | grep -i -m1 -Eo '0x[a-fA-F0-9]{40}' || true)

  if [[ -z "${SEPOLIA_VAULT_ADDRESS}" ]]; then
    echo "Failed to extract Sepolia vault address. Set SEPOLIA_VAULT_ADDRESS manually."
    exit 1
  fi
  echo "Deployed SEPOLIA_VAULT_ADDRESS = ${SEPOLIA_VAULT_ADDRESS}"
else
  echo "Using existing SEPOLIA_VAULT_ADDRESS from env: ${SEPOLIA_VAULT_ADDRESS}"
fi

# --- Configure Arbitrum Pool ---
# echo "Configuring the pool on Arbitrum to point to Sepolia..."
# forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
#   --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
#   --account "${ACCOUNT_NAME}" \
#   --broadcast \
#   --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
#   "${ARBITRUM_POOL_ADDRESS}" "${SEPOLIA_CHAIN_SELECTOR}" "${SEPOLIA_POOL_ADDRESS}" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

# echo "Arbitrum pool configured."

# --- Deposit to Vault on Sepolia ---
echo "Depositing ${AMOUNT} wei to vault on Sepolia at ${SEPOLIA_VAULT_ADDRESS}..."
cast send "${SEPOLIA_VAULT_ADDRESS}" "deposit()" \
  --value "${AMOUNT}" \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --account "${ACCOUNT_NAME}"

echo "Deposit tx sent."

# --- Pre-bridge balance check ---
SEPOLIA_BALANCE_BEFORE=$(cast balance "${WALLET_ADDR}" --erc20 "${SEPOLIA_REBASE_TOKEN_ADDRESS}" --rpc-url "${SEPOLIA_RPC_URL}" || echo "0")
echo "Sepolia token balance before bridge: ${SEPOLIA_BALANCE_BEFORE}"

# --- Approve the router to transfer tokens ---
echo "Approving router ${SEPOLIA_ROUTER} to spend ${AMOUNT} tokens..."
cast send "${SEPOLIA_REBASE_TOKEN_ADDRESS}" "approve(address,uint256)" "${SEPOLIA_ROUTER}" "${AMOUNT}" \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --account "${ACCOUNT_NAME}"

# --- Bridge funds ---
echo "Bridging ${AMOUNT} of ${SEPOLIA_REBASE_TOKEN_ADDRESS} from Sepolia -> Arbitrum (selector ${ARBITRUM_SEPOLIA_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --account "${ACCOUNT_NAME}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "${AMOUNT}" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" "${WALLET_ADDR}" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "${SEPOLIA_LINK_ADDRESS}" "${SEPOLIA_ROUTER}"

echo "Bridge script executed."

# --- Post-bridge balance check ---
SEPOLIA_BALANCE_AFTER=$(cast balance "${WALLET_ADDR}" --erc20 "${SEPOLIA_REBASE_TOKEN_ADDRESS}" --rpc-url "${SEPOLIA_RPC_URL}" || echo "0")
echo "Sepolia token balance after bridge: ${SEPOLIA_BALANCE_AFTER}"

echo "✅ Done bridging Sepolia → Arbitrum."
