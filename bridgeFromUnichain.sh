set -euo pipefail

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
fi

if [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "ERROR: PRIVATE_KEY not set. Export PRIVATE_KEY before running."
  exit 1
fi


echo "Bridging 10000000000000 of ${UNI_REBASE_TOKEN_ADDRESS} from Unichain -> Sepolia (selector ${SEPOLIA_CHAIN_SELECTOR})..."
forge script ./script/BridgeTokens.s.sol:BridgeTokensScript \
  --rpc-url "${UNI_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(uint256,address,address,uint64,address,address)" \
  "10000000000000" "${UNI_REBASE_TOKEN_ADDRESS}" "${PUBLIC_KEY}" "${SEPOLIA_CHAIN_SELECTOR}" "${UNI_LINK_ADDRESS}" "${UNI_ROUTER}"

echo "Bridge Unichain -> Sepolia script executed."
