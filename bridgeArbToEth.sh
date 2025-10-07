#!/bin/bash
set -euo pipefail
# bridgeArbToEth.sh — bridge ARBITRUM -> SEPOLIA

# Load env
if [[ -f .env ]]; then
  # convert CRLF if any (harmless if already LF)
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

# Required variables (adjust list if you intentionally omit some)
require ACCOUNT_NAME
require ARBITRUM_SEPOLIA_RPC_URL
require SEPOLIA_RPC_URL
require ARBITRUM_REBASE_TOKEN_ADDRESS
require ARBITRUM_POOL_ADDRESS
require SEPOLIA_REBASE_TOKEN_ADDRESS
require SEPOLIA_POOL_ADDRESS
require ARBITRUM_LINK_ADDRESS
require ARBITRUM_ROUTER
require SEPOLIA_CHAIN_SELECTOR
require ARBITRUM_SEPOLIA_CHAIN_SELECTOR
require AMOUNT

WALLET_ADDR=$(cast wallet address --account "${ACCOUNT_NAME}")
echo "Using account: ${ACCOUNT_NAME} -> ${WALLET_ADDR}"

# If ARBITRUM_VAULT_ADDRESS not set in env, deploy VaultDeployer on Arbitrum
if [[ -z "${ARBITRUM_VAULT_ADDRESS:-}" ]]; then
  echo "ARBITRUM_VAULT_ADDRESS not provided — deploying Vault on Arbitrum..."
  # Deploy via your VaultDeployer script and capture returned address
  DEPLOY_OUTPUT=$(forge script ./script/Deployer.s.sol:VaultDeployer \
    --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
    --account "${ACCOUNT_NAME}" \
    --broadcast \
    --sig "run(address)" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" 2>&1)

  echo "${DEPLOY_OUTPUT}" | sed -n '1,200p'

  # Try to extract "vault: contract Vault 0x..." or "vault: contract Vault" return line
  ARBITRUM_VAULT_ADDRESS=$(echo "${DEPLOY_OUTPUT}" | grep -i -m1 -Eo '0x[a-fA-F0-9]{40}' || true)

  if [[ -z "${ARBITRUM_VAULT_ADDRESS}" ]]; then
    echo "Failed to extract vault address from forge output. Print full output above and set ARBITRUM_VAULT_ADDRESS manually if needed."
    exit 1
  fi
  echo "Deployed ARBITRUM_VAULT_ADDRESS = ${ARBITRUM_VAULT_ADDRESS}"
else
  echo "Using existing ARBITRUM_VAULT_ADDRESS from env: ${ARBITRUM_VAULT_ADDRESS}"
fi

# Configure the Sepolia pool so it knows the Arbitrum pool/token (run on Sepolia)
# echo "Configuring the pool on Sepolia to point to Arbitrum..."
# forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
#   --rpc-url "${SEPOLIA_RPC_URL}" \
#   --account "${ACCOUNT_NAME}" \
#   --broadcast \
#   --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
#   "${SEPOLIA_POOL_ADDRESS}" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "${ARBITRUM_POOL_ADDRESS}" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

# echo "Sepolia pool configured."

# Deposit funds to the Arbitrum Vault
echo "Depositing ${AMOUNT} wei to vault on Arbitrum at ${ARBITRUM_VAULT_ADDRESS}..."
cast send "${ARBITRUM_VAULT_ADDRESS}" "deposit()" \
  --value "${AMOUNT}" \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --account "${ACCOUNT_NAME}"

echo "Deposit tx sent."

# Optional: show pre-bridge balance (ERC20) on Arbitrum
ARBITRUM_BALANCE_BEFORE=$(cast balance "${WALLET_ADDR}" --erc20 "${ARBITRUM_REBASE_TOKEN_ADDRESS}" --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" || echo "0")
echo "Arbitrum token balance before bridge: ${ARBITRUM_BALANCE_BEFORE}"

# Bridge: run BridgeTokensScript on Arbitrum to send token -> Sepolia
echo "Bridging ${AMOUNT} of ${ARBITRUM_REBASE_TOKEN_ADDRESS} from Arbitrum -> Sepolia (selector ${SEPOLIA_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --account "${ACCOUNT_NAME}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "${AMOUNT}" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" "${WALLET_ADDR}" "${SEPOLIA_CHAIN_SELECTOR}" "${ARBITRUM_LINK_ADDRESS}" "${ARBITRUM_ROUTER}"

echo "Bridge script executed."

# Show post-bridge balance
ARBITRUM_BALANCE_AFTER=$(cast balance "${WALLET_ADDR}" --erc20 "${ARBITRUM_REBASE_TOKEN_ADDRESS}" --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" || echo "0")
echo "Arbitrum token balance after bridge: ${ARBITRUM_BALANCE_AFTER}"

echo "Done."
