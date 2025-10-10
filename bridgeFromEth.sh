set -euo pipefail

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
fi

if [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "ERROR: PRIVATE_KEY not set. Export PRIVATE_KEY before running."
  exit 1
fi

echo "Bridging 10000000000000 of ${SEPOLIA_REBASE_TOKEN_ADDRESS} from Sepolia -> Arbitrum (selector ${ARBITRUM_SEPOLIA_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "10000000000000" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "${SEPOLIA_LINK_ADDRESS}" "${SEPOLIA_ROUTER}"

echo "Bridge Sepolia -> Arbitrum script executed."

echo "Bridging 20000000000000 of ${SEPOLIA_REBASE_TOKEN_ADDRESS} from Sepolia -> Base (selector ${BASE_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "20000000000000" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${BASE_CHAIN_SELECTOR}" "${SEPOLIA_LINK_ADDRESS}" "${SEPOLIA_ROUTER}"

echo "Bridge Sepolia -> Base script executed."

echo "Bridging 30000000000000 of ${SEPOLIA_REBASE_TOKEN_ADDRESS} from Sepolia -> Unichain (selector ${UNI_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "30000000000000" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${UNI_CHAIN_SELECTOR}" "${SEPOLIA_LINK_ADDRESS}" "${SEPOLIA_ROUTER}"

echo "Bridge Sepolia -> Unichain script executed."

echo "Bridging 40000000000000 of ${SEPOLIA_REBASE_TOKEN_ADDRESS} from Sepolia -> OP (selector ${OP_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "40000000000000" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${OP_CHAIN_SELECTOR}" "${SEPOLIA_LINK_ADDRESS}" "${SEPOLIA_ROUTER}"

echo "Bridge Sepolia -> OP script executed."

echo "Bridging 50000000000000 of ${SEPOLIA_REBASE_TOKEN_ADDRESS} from Sepolia -> Soneium (selector ${SONEIUM_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "50000000000000" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${SONEIUM_CHAIN_SELECTOR}" "${SEPOLIA_LINK_ADDRESS}" "${SEPOLIA_ROUTER}"

echo "Bridge Sepolia -> Soneium script executed."