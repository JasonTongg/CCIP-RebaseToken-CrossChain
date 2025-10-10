set -euo pipefail

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
fi

if [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "ERROR: PRIVATE_KEY not set. Export PRIVATE_KEY before running."
  exit 1
fi

echo
echo "Start Configure pool from Arbitrum"
echo

echo "Configuring the pool on Arbitrum to point to Sepolia..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${ARBITRUM_POOL_ADDRESS}" "${SEPOLIA_CHAIN_SELECTOR}" "${SEPOLIA_POOL_ADDRESS}" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0
  
echo "Configuring the pool on Arbitrum to point to Base..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${ARBITRUM_POOL_ADDRESS}" "${BASE_CHAIN_SELECTOR}" "${BASE_POOL_ADDRESS}" "${BASE_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on Arbitrum to point to OP..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${ARBITRUM_POOL_ADDRESS}" "${OP_CHAIN_SELECTOR}" "${OP_POOL_ADDRESS}" "${OP_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on Arbitrum to point to Soneium..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${ARBITRUM_POOL_ADDRESS}" "${SONEIUM_CHAIN_SELECTOR}" "${SONEIUM_POOL_ADDRESS}" "${SONEIUM_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo
echo "Start Configure pool from Sepolia"
echo

echo "Configuring the pool on Sepolia to point to Arbitrum..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${SEPOLIA_POOL_ADDRESS}" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "${ARBITRUM_POOL_ADDRESS}" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on Sepolia to point to Base..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${SEPOLIA_POOL_ADDRESS}" "${BASE_CHAIN_SELECTOR}" "${BASE_POOL_ADDRESS}" "${BASE_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on Sepolia to point to OP..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${SEPOLIA_POOL_ADDRESS}" "${OP_CHAIN_SELECTOR}" "${OP_POOL_ADDRESS}" "${OP_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on Sepolia to point to Unichain..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${SEPOLIA_POOL_ADDRESS}" "${UNI_CHAIN_SELECTOR}" "${UNI_POOL_ADDRESS}" "${UNI_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on Sepolia to point to Soneium..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${SEPOLIA_POOL_ADDRESS}" "${SONEIUM_CHAIN_SELECTOR}" "${SONEIUM_POOL_ADDRESS}" "${SONEIUM_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo
echo "Start Configure pool from Base"
echo

echo "Configuring the pool on Base to point to Sepolia..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${BASE_POOL_ADDRESS}" "${SEPOLIA_CHAIN_SELECTOR}" "${SEPOLIA_POOL_ADDRESS}" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on Base to point to Arbitrum..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${BASE_POOL_ADDRESS}" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "${ARBITRUM_POOL_ADDRESS}" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on Base to point to OP..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${BASE_POOL_ADDRESS}" "${OP_CHAIN_SELECTOR}" "${OP_POOL_ADDRESS}" "${OP_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo
echo "Start Configure pool from OP"
echo

echo "Configuring the pool on OP to point to Sepolia..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${OP_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${OP_POOL_ADDRESS}" "${SEPOLIA_CHAIN_SELECTOR}" "${SEPOLIA_POOL_ADDRESS}" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on OP to point to Arbitrum..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${OP_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${OP_POOL_ADDRESS}" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "${ARBITRUM_POOL_ADDRESS}" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on OP to point to Base..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${OP_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${OP_POOL_ADDRESS}" "${BASE_CHAIN_SELECTOR}" "${BASE_POOL_ADDRESS}" "${BASE_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo
echo "Start Configure pool from Unichain"
echo

echo "Configuring the pool on Unichain to point to Sepolia..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${UNI_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${UNI_POOL_ADDRESS}" "${SEPOLIA_CHAIN_SELECTOR}" "${SEPOLIA_POOL_ADDRESS}" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo
echo "Start Configure pool from Soneium"
echo

echo "Configuring the pool on Soneium to point to Sepolia..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${SONEIUM_MINATO_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${SONEIUM_POOL_ADDRESS}" "${SEPOLIA_CHAIN_SELECTOR}" "${SEPOLIA_POOL_ADDRESS}" "${SEPOLIA_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0

echo "Configuring the pool on Soneium to point to Arbitrum..."
forge script ./script/ConfigurePool.s.sol:ConfigurePoolScript \
  --rpc-url "${SONEIUM_MINATO_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  --sig "run(address,uint64,address,address,bool,uint128,uint128,bool,uint128,uint128)" \
  "${SONEIUM_POOL_ADDRESS}" "${ARBITRUM_SEPOLIA_CHAIN_SELECTOR}" "${ARBITRUM_POOL_ADDRESS}" "${ARBITRUM_REBASE_TOKEN_ADDRESS}" false 0 0 false 0 0