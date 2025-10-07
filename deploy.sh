#!/bin/bash
set -euo pipefail

# === USER CONFIG / REQUIRED ENV VARS ===
# You must export these before running, or fill them below:
# PRIVATE_KEY
# ARBITRUM_SEPOLIA_RPC_URL
# SEPOLIA_RPC_URL

# Example: export PRIVATE_KEY=0x....
# Example: export ARBITRUM_SEPOLIA_RPC_URL=https://arb-sepolia.infura.io/v3/...
# Example: export SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/...

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
fi

# Basic validation
if [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "ERROR: PRIVATE_KEY not set. Export PRIVATE_KEY before running."
  exit 1
fi
if [[ -z "${ARBITRUM_SEPOLIA_RPC_URL:-}" ]]; then
  echo "ERROR: ARBITRUM_SEPOLIA_RPC_URL not set. Export it before running."
  exit 1
fi
if [[ -z "${SEPOLIA_RPC_URL:-}" ]]; then
  echo "ERROR: SEPOLIA_RPC_URL not set. Export it before running."
  exit 1
fi

# === PARAMETERS (customize) ===
AMOUNT=100000

# === ARBITRUM SEPOLIA CONFIGURATION ===
ARBITRUM_SEPOLIA_REGISTRY_MODULE_OWNER_CUSTOM="0xE625f0b8b0Ac86946035a7729Aba124c8A64cf69"
ARBITRUM_SEPOLIA_TOKEN_ADMIN_REGISTRY="0x8126bE56454B628a88C17849B9ED99dd5a11Bd2f"
ARBITRUM_SEPOLIA_ROUTER="0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165"
ARBITRUM_SEPOLIA_RNM_PROXY_ADDRESS="0x9527E2d01A3064ef6b50c1Da1C0cC523803BCFF2"
ARBITRUM_SEPOLIA_CHAIN_SELECTOR="3478487238524512106"
ARBITRUM_SEPOLIA_LINK_ADDRESS="0xb1D4538B4571d411F07960EF2838Ce337FE1E80E"

# === SEPOLIA CONFIGURATION ===
SEPOLIA_REGISTRY_MODULE_OWNER_CUSTOM="0x62e731218d0D47305aba2BE3751E7EE9E5520790"
SEPOLIA_TOKEN_ADMIN_REGISTRY="0x95F29FEE11c5C55d26cCcf1DB6772DE953B37B82"
SEPOLIA_ROUTER="0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59"
SEPOLIA_RNM_PROXY_ADDRESS="0xba3f6251de62dED61Ff98590cB2fDf6871FbB991"
SEPOLIA_CHAIN_SELECTOR="16015286601757825753"
SEPOLIA_LINK_ADDRESS="0x779877A7B0D9E8603169DdbD7836e478b4624789"

# === Optional: addresses you may already have (if left blank, script will deploy) ===
# If you already have Sepolia pool/address and Sepolia rebase token, set these to skip deploy.
SEPOLIA_REBASE_TOKEN_ADDRESS="${SEPOLIA_REBASE_TOKEN_ADDRESS:-}"
SEPOLIA_POOL_ADDRESS="${SEPOLIA_POOL_ADDRESS:-}"

echo "Foundry version:"
forge --version

# Load .env if exists (keeps backward compatibility)
if [[ -f .env ]]; then
  echo "Sourcing .env"
  # shellcheck disable=SC1091
  source .env
fi

echo "Building project..."
forge build

# ---------------------------
# DEPLOY token + pool to Arbitrum Sepolia using your TokenAndPoolDeployer script
# ---------------------------
echo
echo "==> Deploying Rebase token and pool on Arbitrum Sepolia via TokenAndPoolDeployer script"
echo "Running TokenAndPoolDeployer on ARBITRUM_SEPOLIA_RPC_URL..."
# use forge script to execute the TokenAndPoolDeployer.run() on Arbitrum Sepolia
# This will deploy both token and pool (your TokenAndPoolDeployer returns them)
forge script script/Deployer.s.sol:TokenAndPoolDeployer \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  -vvvv

echo "NOTE: TokenAndPoolDeployer prints addresses in the transaction logs. Inspect output to capture deployed addresses."
echo "If you want to capture the deployed addresses programmatically, consider emitting events in the Script or using an explorer to look up the deploy transactions."

# ---------------------------
# If you already had deployed Sepolia token+pool and want to use them, keep SEPOLIA_* variables set
# If not, you can deploy them with the same TokenAndPoolDeployer but targeting Sepolia RPC.
# Here I will check if SEPOLIA_REBASE_TOKEN_ADDRESS is set; if not, deploy to Sepolia too.
# ---------------------------
if [[ -z "${SEPOLIA_REBASE_TOKEN_ADDRESS}" || -z "${SEPOLIA_POOL_ADDRESS}" ]]; then
  echo
  echo "==> Deploying Rebase token and pool on Sepolia (because SEPOLIA_REBASE_TOKEN_ADDRESS or SEPOLIA_POOL_ADDRESS not set)"
  forge script script/Deployer.s.sol:TokenAndPoolDeployer \
    --rpc-url "${SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    -vvvv

  echo "NOTE: After completion, capture SEPOLIA_REBASE_TOKEN_ADDRESS and SEPOLIA_POOL_ADDRESS from the transaction logs or explorer and export them for subsequent steps."
  echo "Exiting so you can set those addresses in env and re-run the script for the remaining steps."
  exit 0
fi

# From here we assume SEPOLIA_REBASE_TOKEN_ADDRESS and SEPOLIA_POOL_ADDRESS exist (set by user or from previous step)
echo
echo "Using existing Sepolia token/pool:"
echo "  SEPOLIA_REBASE_TOKEN_ADDRESS = ${SEPOLIA_REBASE_TOKEN_ADDRESS}"
echo "  SEPOLIA_POOL_ADDRESS         = ${SEPOLIA_POOL_ADDRESS}"

# ---------------------------
# Grant mint & burn role on Arbitrum token to the pool (Arbitrum)
# If you deployed Arbitrum token+pool earlier, you need to grant roles. We'll perform cast sends to do that.
# For safety, we expect the token & pool addresses to be printed by the TokenAndPoolDeployer run earlier,
# so update these variables manually if needed.
# ---------------------------
# NOTE: This section assumes you captured ARBITRUM_REBASE_TOKEN_ADDRESS and ARBITRUM_POOL_ADDRESS from the TokenAndPoolDeployer logs.
# If you did, export them as env vars before running.
if [[ -z "${ARBITRUM_REBASE_TOKEN_ADDRESS:-}" || -z "${ARBITRUM_POOL_ADDRESS:-}" ]]; then
  echo
  echo "WARNING: ARBITRUM_REBASE_TOKEN_ADDRESS or ARBITRUM_POOL_ADDRESS not set. Please export them using the addresses shown in the TokenAndPoolDeployer output, then re-run this script to continue."
  exit 1
fi

echo
echo "Granting mint and burn role to the Arbitrum pool on the Arbitrum token..."
cast send "${ARBITRUM_REBASE_TOKEN_ADDRESS}" \
  "grantMintAndBurnRole(address)" "${ARBITRUM_POOL_ADDRESS}" \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  -v

echo
echo "Registering admin and setting pool in CCIP registries on Arbitrum Sepolia..."
cast send "${ARBITRUM_SEPOLIA_REGISTRY_MODULE_OWNER_CUSTOM}" "registerAdminViaOwner(address)" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" --private-key "${PRIVATE_KEY}" -v
cast send "${ARBITRUM_SEPOLIA_TOKEN_ADMIN_REGISTRY}" "acceptAdminRole(address)" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" --private-key "${PRIVATE_KEY}" -v
cast send "${ARBITRUM_SEPOLIA_TOKEN_ADMIN_REGISTRY}" "setPool(address,address)" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" "${ARBITRUM_POOL_ADDRESS}" --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" --private-key "${PRIVATE_KEY}" -v

# ---------------------------
# Configure pool on Sepolia to point to Arbitrum Sepolia using your ConfigurePoolScript
# ---------------------------
echo
echo "Configuring Sepolia pool to point to Arbitrum Sepolia via ConfigurePoolScript"
forge script script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${SEPOLIA_POOL_ADDRESS}" \
  "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" \
  "${ARBITRUM_POOL_ADDRESS}" \
  "${ARBITRUM_REBASE_TOKEN_ADDRESS}" \
  "false" 0 0 "false" 0 0 \
  -vvvv

# ---------------------------
# Configure Arbitrum Sepolia pool to point to Sepolia using ConfigurePoolScript (on Arbitrum RPC)
# ---------------------------
echo
echo "Configuring Arbitrum Sepolia pool to point to Sepolia via ConfigurePoolScript (run on ARBITRUM_SEPOLIA_RPC_URL)"
forge script script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${ARBITRUM_POOL_ADDRESS}" \
  "${SEPOLIA_CHAIN_SELECTOR}" \
  "${SEPOLIA_POOL_ADDRESS}" \
  "${SEPOLIA_REBASE_TOKEN_ADDRESS}" \
  "false" 0 0 "false" 0 0 \
  -vvvv

# ---------------------------
# Bridge from Sepolia to Arbitrum Sepolia using BridgeTokensScript
# ---------------------------
# echo
# echo "Bridging funds from Sepolia to Arbitrum Sepolia using BridgeTokensScript"
# # The correct run signature for BridgeTokensScript (based on your contract) is:
# # run(uint256 AmountToSend, address tokenToSendAddress, address receiverAddress, uint64 destinationChainSelector, address linkTokenAddress, address routerAddress)
# # So pass args in that order: AMOUNT, token, receiver, chainSelector, linkToken, router
# forge script script/BridgeTokens.s.sol:BridgeTokensScript \
#   --rpc-url "${SEPOLIA_RPC_URL}" \
#   --private-key "${PRIVATE_KEY}" \
#   --broadcast \
#   --sig "run(uint256,address,address,uint64,address,address)" \
#   "${AMOUNT}" \
#   "${SEPOLIA_REBASE_TOKEN_ADDRESS}" \
#   "$(cast wallet address --key ${PRIVATE_KEY})" \
#   "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" \
#   "${SEPOLIA_LINK_ADDRESS}" \
#   "${SEPOLIA_ROUTER}" \
#   -vvvv

# echo
# echo "Done. Inspect the TX logs (forge output) and explorers to confirm successful operations."
