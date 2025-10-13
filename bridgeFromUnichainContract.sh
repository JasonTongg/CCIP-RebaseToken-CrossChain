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
  UNI_SEPOLIA_RPC_URL
  UNI_REBASE_TOKEN_ADDRESS
  UNI_LINK_ADDRESS
  UNI_ROUTER
  UNICHAIN_BRIDGE_CONTRACT
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

  echo "🔁 Approving ${amount} of ${UNI_REBASE_TOKEN_ADDRESS} for Bridge contract..."
  cast send "${UNI_REBASE_TOKEN_ADDRESS}" \
    "approve(address,uint256)" \
    "${UNICHAIN_BRIDGE_CONTRACT}" \
    "${amount}" \
    --rpc-url "${UNI_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --gas-limit 200000

  echo "🔁 Approving 5000000000000000000 LINK for Bridge contract..."
  cast send "${UNI_LINK_ADDRESS}" \
    "approve(address,uint256)" \
    "${UNICHAIN_BRIDGE_CONTRACT}" \
    "5000000000000000000" \
    --rpc-url "${UNI_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --gas-limit 200000

  echo "🔁 Bridging ${amount} from Unichain → ${destName}..."
  cast send "${UNICHAIN_BRIDGE_CONTRACT}" \
    "bridgeTokens(uint256,address,address,uint64,address,address)" \
    "${amount}" \
    "${UNI_REBASE_TOKEN_ADDRESS}" \
    "${PUBLIC_KEY}" \
    "${destSelector}" \
    "${UNI_LINK_ADDRESS}" \
    "${UNI_ROUTER}" \
    --rpc-url "${UNI_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --gas-limit 6000000

  echo "✅ Bridge to ${destName} executed."
  echo ""
}

call_bridge "10000000000000" "${SEPOLIA_CHAIN_SELECTOR}" "Sepolia"

echo "🎉 All bridge calls completed successfully!"
