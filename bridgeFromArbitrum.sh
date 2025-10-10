set -euo pipefail

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
fi

if [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "ERROR: PRIVATE_KEY not set. Export PRIVATE_KEY before running."
  exit 1
fi

echo "Bridging 10000000000000 of ${ARBITRUM_REBASE_TOKEN_ADDRESS} from Arbitrum -> Base (selector ${BASE_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "10000000000000" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${BASE_CHAIN_SELECTOR}" "${ARBITRUM_LINK_ADDRESS}" "${ARBITRUM_ROUTER}"

echo "Bridge Arbitrum -> Base script executed."

echo "Bridging 20000000000000 of ${ARBITRUM_REBASE_TOKEN_ADDRESS} from Arbitrum -> Sepolia (selector ${SEPOLIA_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "20000000000000" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${SEPOLIA_CHAIN_SELECTOR}" "${ARBITRUM_LINK_ADDRESS}" "${ARBITRUM_ROUTER}"

echo "Bridge Arbitrum -> Sepolia script executed."

echo "Bridging 30000000000000 of ${ARBITRUM_REBASE_TOKEN_ADDRESS} from Arbitrum -> OP (selector ${OP_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "30000000000000" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${OP_CHAIN_SELECTOR}" "${ARBITRUM_LINK_ADDRESS}" "${ARBITRUM_ROUTER}"

echo "Bridge Arbitrum -> OP script executed."

echo "Bridging 40000000000000 of ${ARBITRUM_REBASE_TOKEN_ADDRESS} from Arbitrum -> Soneium (selector ${SONEIUM_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "40000000000000" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${SONEIUM_CHAIN_SELECTOR}" "${ARBITRUM_LINK_ADDRESS}" "${ARBITRUM_ROUTER}"

echo "Bridge Arbitrum -> Soneium script executed."