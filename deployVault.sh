set -euo pipefail

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
fi

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
if [[ -z "${BASE_SEPOLIA_RPC_URL:-}" ]]; then
  echo "ERROR: BASE_SEPOLIA_RPC_URL not set. Export it before running."
  exit 1
fi
if [[ -z "${OP_SEPOLIA_RPC_URL:-}" ]]; then
  echo "ERROR: OP_SEPOLIA_RPC_URL not set. Export it before running."
  exit 1
fi
if [[ -z "${UNI_SEPOLIA_RPC_URL:-}" ]]; then
  echo "ERROR: UNI_SEPOLIA_RPC_URL not set. Export it before running."
  exit 1
fi
if [[ -z "${SONEIUM_MINATO_RPC_URL:-}" ]]; then
  echo "ERROR: SONEIUM_MINATO_RPC_URL not set. Export it before running."
  exit 1
fi
if [[ -z "${ACCOUNT_NAME:-}" ]]; then
  echo "ERROR: ACCOUNT_NAME not set. Export it before running."
  exit 1
fi
if [[ -z "${ARBITRUM_REBASE_TOKEN_ADDRESS:-}" ]]; then
  echo "ERROR: ARBITRUM_REBASE_TOKEN_ADDRESS not set. Export it before running."
  exit 1
fi
if [[ -z "${SEPOLIA_REBASE_TOKEN_ADDRESS:-}" ]]; then
  echo "ERROR: SEPOLIA_REBASE_TOKEN_ADDRESS not set. Export it before running."
  exit 1
fi
if [[ -z "${BASE_REBASE_TOKEN_ADDRESS:-}" ]]; then
  echo "ERROR: BASE_REBASE_TOKEN_ADDRESS not set. Export it before running."
  exit 1
fi
if [[ -z "${OP_REBASE_TOKEN_ADDRESS:-}" ]]; then
  echo "ERROR: OP_REBASE_TOKEN_ADDRESS not set. Export it before running."
  exit 1
fi
if [[ -z "${UNI_SEPOLIA_RPC_URL:-}" ]]; then
  echo "ERROR: UNI_SEPOLIA_RPC_URL not set. Export it before running."
  exit 1
fi
if [[ -z "${SONEIUM_MINATO_RPC_URL:-}" ]]; then
  echo "ERROR: SONEIUM_MINATO_RPC_URL not set. Export it before running."
  exit 1
fi

echo "Deploy vault on Arbitrum..."
forge script ./script/Deployer.s.sol:VaultDeployer \
    --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    --sig "run(address)" "${ARBITRUM_REBASE_TOKEN_ADDRESS}"

echo "Deploy vault on Sepolia..."
forge script ./script/Deployer.s.sol:VaultDeployer \
    --rpc-url "${SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    --sig "run(address)" "${SEPOLIA_REBASE_TOKEN_ADDRESS}"

echo "Deploy vault on Base..."
forge script ./script/Deployer.s.sol:VaultDeployer \
    --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    --sig "run(address)" "${BASE_REBASE_TOKEN_ADDRESS}"

echo "Deploy vault on OP..."
forge script ./script/Deployer.s.sol:VaultDeployer \
    --rpc-url "${OP_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    --sig "run(address)" "${OP_REBASE_TOKEN_ADDRESS}"

echo "Deploy vault on Unichain..."
forge script ./script/Deployer.s.sol:VaultDeployer \
    --rpc-url "${UNI_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    --sig "run(address)" "${UNI_REBASE_TOKEN_ADDRESS}"

echo "Deploy vault on Soneium..."
forge script ./script/Deployer.s.sol:VaultDeployer \
    --rpc-url "${SONEIUM_MINATO_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    --sig "run(address)" "${SONEIUM_REBASE_TOKEN_ADDRESS}"