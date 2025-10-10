set -euo pipefail

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
fi

if [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "ERROR: PRIVATE_KEY not set. Export PRIVATE_KEY before running."
  exit 1
fi


echo "Bridging 10000000000000 of ${SONEIUM_REBASE_TOKEN_ADDRESS} from Soneium -> Sepolia (selector ${SEPOLIA_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${SONEIUM_MINATO_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "10000000000000" "${SONEIUM_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${SEPOLIA_CHAIN_SELECTOR}" "${SONEIUM_LINK_ADDRESS}" "${SONEIUM_ROUTER}"

echo "Bridge Soneium -> Sepolia script executed."

echo "Bridging 20000000000000 of ${SONEIUM_REBASE_TOKEN_ADDRESS} from Soneium -> Arbitrum (selector ${ARBITRUM_SEPOLIA_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${SONEIUM_MINATO_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "20000000000000" "${SONEIUM_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "${SONEIUM_LINK_ADDRESS}" "${SONEIUM_ROUTER}"

echo "Bridge Soneium -> Arbitrum script executed."