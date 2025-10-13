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

function call_bridge() {
  local amount=$1
  local destSelector=$2
  local destName=$3

  echo "🔁 Approving ${amount} of ${ARBITRUM_REBASE_TOKEN_ADDRESS} for Bridge contract..."
  cast send "${ARBITRUM_REBASE_TOKEN_ADDRESS}" \
    "approve(address,uint256)" \
    "${ARBITRUM_BRIDGE_CONTRACT}" \
    "${amount}" \
    --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --gas-limit 200000

  echo "🔁 Approving 5000000000000000000 LINK for Bridge contract..."
  cast send "${ARBITRUM_LINK_ADDRESS}" \
    "approve(address,uint256)" \
    "${ARBITRUM_BRIDGE_CONTRACT}" \
    "5000000000000000000" \
    --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --gas-limit 200000

  echo "🔁 Bridging ${amount} from Arbitrum → ${destName}..."
  cast send "${ARBITRUM_BRIDGE_CONTRACT}" \
    "bridgeTokens(uint256,address,address,uint64,address,address)" \
    "${amount}" \
    "${ARBITRUM_REBASE_TOKEN_ADDRESS}" \
    "${PUBLIC_KEY}" \
    "${destSelector}" \
    "${ARBITRUM_LINK_ADDRESS}" \
    "${ARBITRUM_ROUTER}" \
    --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --gas-limit 6000000

  echo "✅ Bridge to ${destName} executed."
  echo ""
}

call_bridge "10000000000000" "${BASE_CHAIN_SELECTOR}" "Base"
call_bridge "20000000000000" "${SEPOLIA_CHAIN_SELECTOR}" "Sepolia"
call_bridge "30000000000000" "${OP_CHAIN_SELECTOR}" "Optimism"
call_bridge "40000000000000" "${SONEIUM_CHAIN_SELECTOR}" "Soneium"

echo "🎉 All bridge calls completed successfully!"
