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
  OP_SEPOLIA_RPC_URL
  OP_REBASE_TOKEN_ADDRESS
  OP_LINK_ADDRESS
  OP_ROUTER
  OP_BRIDGE_CONTRACT
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

  echo "🔁 Approving ${amount} of ${OP_REBASE_TOKEN_ADDRESS} for Bridge contract..."
  cast send "${OP_REBASE_TOKEN_ADDRESS}" \
    "approve(address,uint256)" \
    "${OP_BRIDGE_CONTRACT}" \
    "${amount}" \
    --rpc-url "${OP_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --gas-limit 200000

  echo "🔁 Approving 5000000000000000000 LINK for Bridge contract..."
  cast send "${OP_LINK_ADDRESS}" \
    "approve(address,uint256)" \
    "${OP_BRIDGE_CONTRACT}" \
    "5000000000000000000" \
    --rpc-url "${OP_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --gas-limit 200000

  echo "🔁 Bridging ${amount} from OP → ${destName}..."
  cast send "${OP_BRIDGE_CONTRACT}" \
    "bridgeTokens(uint256,address,address,uint64,address,address)" \
    "${amount}" \
    "${OP_REBASE_TOKEN_ADDRESS}" \
    "${PUBLIC_KEY}" \
    "${destSelector}" \
    "${OP_LINK_ADDRESS}" \
    "${OP_ROUTER}" \
    --rpc-url "${OP_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --gas-limit 6000000

  echo "✅ Bridge to ${destName} executed."
  echo ""
}

call_bridge "10000000000000" "${BASE_CHAIN_SELECTOR}" "Base"
call_bridge "20000000000000" "${SEPOLIA_CHAIN_SELECTOR}" "Sepolia"
call_bridge "30000000000000" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "Arbitrum"

echo "🎉 All bridge calls completed successfully!"
