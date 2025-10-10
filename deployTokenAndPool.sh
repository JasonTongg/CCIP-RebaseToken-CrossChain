set -euo pipefail

# === USER CONFIG / REQUIRED ENV VARS ===
# You must export these before running, or fill them below:
# PRIVATE_KEY
# ARBITRUM_SEPOLIA_RPC_URL
# SEPOLIA_RPC_URL

# Example: export PRIVATE_KEY=0x....
# Example: export ARBITRUM_SEPOLIA_RPC_URL=https://arb-sepolia.infura.io/v3/...
# Example: export SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/...

if [[ -f .env ]]; then
  echo "Sourcing .env"
  source .env
fi

# Basic validation
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

# === PARAMETERS (customize) ===
AMOUNT=100000

# === ARBITRUM SEPOLIA CONFIGURATION ===
ARBITRUM_SEPOLIA_REGISTRY_MODULE_OWNER_CUSTOM="0xE625f0b8b0Ac86946035a7729Aba124c8A64cf69"
ARBITRUM_SEPOLIA_TOKEN_ADMIN_REGISTRY="0x8126bE56454B628a88C17849B9ED99dd5a11Bd2f"
ARBITRUM_SEPOLIA_ROUTER="0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165"
ARBITRUM_SEPOLIA_RNM_PROXY_ADDRESS="0x9527E2d01A3064ef6b50c1Da1C0cC523803BCFF2"
ARBITRUM_SEPOLIA_CHAIN_SELECTOR="3478487238524512106"
ARBITRUM_SEPOLIA_LINK_ADDRESS="0xb1D4538B4571d411F07960EF2838Ce337FE1E80E"

# === SEPOLIA CONFIGURATION ===
SEPOLIA_REGISTRY_MODULE_OWNER_CUSTOM="0x62e731218d0D47305aba2BE3751E7EE9E5520790"
SEPOLIA_TOKEN_ADMIN_REGISTRY="0x95F29FEE11c5C55d26cCcf1DB6772DE953B37B82"
SEPOLIA_ROUTER="0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59"
SEPOLIA_RNM_PROXY_ADDRESS="0xba3f6251de62dED61Ff98590cB2fDf6871FbB991"
SEPOLIA_CHAIN_SELECTOR="16015286601757825753"
SEPOLIA_LINK_ADDRESS="0x779877A7B0D9E8603169DdbD7836e478b4624789"

# === BASE CONFIGURATION ===
BASE_REGISTRY_MODULE_OWNER_CUSTOM="0x8A55C61227f26a3e2f217842eCF20b52007bAaBe"
BASE_TOKEN_ADMIN_REGISTRY="0x736D0bBb318c1B27Ff686cd19804094E66250e17"
BASE_RNM_PROXY_ADDRESS="0x99360767a4705f68CcCb9533195B761648d6d807"
BASE_CHAIN_SELECTOR="10344971235874465080"
BASE_LINK_ADDRESS="0xE4aB69C077896252FAFBD49EFD26B5D171A32410"
BASE_ROUTER="0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93"

# === OP CONFIGURATION ===
OP_REGISTRY_MODULE_OWNER_CUSTOM="0x49c4ba01dc6F5090f9df43Ab8F79449Db91A0CBB"
OP_TOKEN_ADMIN_REGISTRY="0x1d702b1FA12F347f0921C722f9D9166F00DEB67A"
OP_RNM_PROXY_ADDRESS="0xb40A3109075965cc09E93719e33E748abf680dAe"
OP_CHAIN_SELECTOR="5224473277236331295"
OP_LINK_ADDRESS="0xE4aB69C077896252FAFBD49EFD26B5D171A32410"
OP_ROUTER="0x114A20A10b43D4115e5aeef7345a1A71d2a60C57"

# === BNB CONFIGURATION ===
UNI_REGISTRY_MODULE_OWNER_CUSTOM="0x504f424F6eFe984d16B7ff2A1a4edf0Efe0D6A49"
UNI_TOKEN_ADMIN_REGISTRY="0xf2d17820416B692c52515A828B8A26d2f22cafce"
UNI_RNM_PROXY_ADDRESS="0x6dFD89Ff6bDa2EA420Dfe6Cc57E7e1F9cf610925"
UNI_CHAIN_SELECTOR="14135854469784514356"
UNI_LINK_ADDRESS="0xda40816f278Cd049c137F6612822D181065EBfB4"
UNI_ROUTER="0x5b7D7CDf03871dc9Eb00830B027e70A75bd3DC95"

# === POL CONFIGURATION ===
SONEIUM_REGISTRY_MODULE_OWNER_CUSTOM="0xe06fE3AEfef3a27b8BF0edd5ae834B006EdE3aa1"
SONEIUM_TOKEN_ADMIN_REGISTRY="0xD2334a6f4f79CE462193EAcB89eB2c29Ae552750"
SONEIUM_RNM_PROXY_ADDRESS="0x6172F4f60eEE3876cF83318DEe4477BfAf15Ffd3"
SONEIUM_CHAIN_SELECTOR="686603546605904534"
SONEIUM_LINK_ADDRESS="0x7ea13478Ea3961A0e8b538cb05a9DF0477c79Cd2"
SONEIUM_ROUTER="0x443a1bce545d56E2c3f20ED32eA588395FFce0f4"

# === Optional: addresses you may already have (if left blank, script will deploy) ===
# If you already have Sepolia pool/address and Sepolia rebase token, set these to skip deploy.
SEPOLIA_REBASE_TOKEN_ADDRESS="${SEPOLIA_REBASE_TOKEN_ADDRESS:-}"
SEPOLIA_POOL_ADDRESS="${SEPOLIA_POOL_ADDRESS:-}"

echo "Foundry version:"
forge --version

# Load .env if exists (keeps backward compatibility)
if [[ -f .env ]]; then
  echo "Sourcing .env"
  # shellcheck disable=SC1091
  source .env
fi

echo "Building project..."
forge build

echo
echo "==> Deploying Rebase token and pool on Arbitrum Sepolia"
forge script script/Deployer.s.sol:TokenAndPoolDeployer \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}" \
  --broadcast \
  -vvvv

echo "==> Deploying Rebase token and pool on Sepolia"
forge script script/Deployer.s.sol:TokenAndPoolDeployer \
    --rpc-url "${SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    -vvvv

echo "==> Deploying Rebase token and pool on Base Sepolia"
forge script script/Deployer.s.sol:TokenAndPoolDeployer \
    --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    -vvvv

echo "==> Deploying Rebase token and pool on OP Sepolia"
forge script script/Deployer.s.sol:TokenAndPoolDeployer \
    --rpc-url "${OP_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    --legacy \
    -vvvv

echo "==> Deploying Rebase token and pool on SONEIUM Sepolia"
forge script script/Deployer.s.sol:TokenAndPoolDeployer \
    --rpc-url "${SONEIUM_MINATO_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    -vvvv \
    --sig "run(address,address,address,address)" \
    "${SONEIUM_RNM_PROXY_ADDRESS}" "${SONEIUM_ROUTER}" "${SONEIUM_REGISTRY_MODULE_OWNER_CUSTOM}" "${SONEIUM_TOKEN_ADMIN_REGISTRY}"

echo "==> Deploying Rebase token and pool on UNICHAIN Sepolia"
forge script script/Deployer.s.sol:TokenAndPoolDeployer \
    --rpc-url "${UNI_SEPOLIA_RPC_URL}" \
    --private-key "${PRIVATE_KEY}" \
    --broadcast \
    -vvvv \
    --sig "run(address,address,address,address)" \
    "${UNI_RNM_PROXY_ADDRESS}" "${UNI_ROUTER}" "${UNI_REGISTRY_MODULE_OWNER_CUSTOM}" "${UNI_TOKEN_ADMIN_REGISTRY}"