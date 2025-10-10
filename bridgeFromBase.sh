set -euo pipefail

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
fi

if [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "ERROR: PRIVATE_KEY not set. Export PRIVATE_KEY before running."
  exit 1
fi


echo "Bridging 10000000000000 of ${BASE_REBASE_TOKEN_ADDRESS} from Base -> Sepolia (selector ${SEPOLIA_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "10000000000000" "${BASE_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${SEPOLIA_CHAIN_SELECTOR}" "${BASE_LINK_ADDRESS}" "${BASE_ROUTER}"

echo "Bridge Base -> Sepolia script executed."

echo "Bridging 20000000000000 of ${BASE_REBASE_TOKEN_ADDRESS} from Base -> OP (selector ${OP_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "20000000000000" "${BASE_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${OP_CHAIN_SELECTOR}" "${BASE_LINK_ADDRESS}" "${BASE_ROUTER}"

echo "Bridge Base -> OP script executed."

echo "Bridging 30000000000000 of ${BASE_REBASE_TOKEN_ADDRESS} from Base -> Arbitrum (selector ${ARBITRUM_SEPOLIA_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "30000000000000" "${BASE_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "${BASE_LINK_ADDRESS}" "${BASE_ROUTER}"

echo "Bridge Base -> Arbitrum script executed."