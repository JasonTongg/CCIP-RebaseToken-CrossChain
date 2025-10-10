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
echo "Deposit vault on Sepolia..."
echo

echo "Depositing ${AMOUNT} wei to vault on Sepolia at ${SEPOLIA_VAULT_ADDRESS}..."
cast send "${SEPOLIA_VAULT_ADDRESS}" "deposit()" \
  --value "${AMOUNT}" \
  --rpc-url "${SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}"

echo "Deposit tx sent."

SEPOLIA_BALANCE_BEFORE=$(cast balance "${PUBLIC_KEY}" --erc20 "${SEPOLIA_REBASE_TOKEN_ADDRESS}" --rpc-url "${SEPOLIA_RPC_URL}" || echo "0")
echo "Sepolia token balance: ${SEPOLIA_BALANCE_BEFORE}"

echo
echo "Deposit vault on Arbitrum..."
echo

echo "Depositing ${AMOUNT} wei to vault on Arbitrum at ${ARBITRUM_VAULT_ADDRESS}..."
cast send "${ARBITRUM_VAULT_ADDRESS}" "deposit()" \
  --value "${AMOUNT}" \
  --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}"

echo "Deposit tx sent."

ARBITRUM_BALANCE_BEFORE=$(cast balance "${PUBLIC_KEY}" --erc20 "${ARBITRUM_REBASE_TOKEN_ADDRESS}" --rpc-url "${ARBITRUM_SEPOLIA_RPC_URL}" || echo "0")
echo "Arbitrum token balance: ${ARBITRUM_BALANCE_BEFORE}"

echo
echo "Deposit vault on Base..."
echo

echo "Depositing ${AMOUNT} wei to vault on Base at ${BASE_VAULT_ADDRESS}..."
cast send "${BASE_VAULT_ADDRESS}" "deposit()" \
  --value "${AMOUNT}" \
  --rpc-url "${BASE_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}"

echo "Deposit tx sent."

BASE_BALANCE_BEFORE=$(cast balance "${PUBLIC_KEY}" --erc20 "${BASE_REBASE_TOKEN_ADDRESS}" --rpc-url "${BASE_SEPOLIA_RPC_URL}" || echo "0")
echo "Base token balance: ${BASE_BALANCE_BEFORE}"

echo
echo "Deposit vault on OP..."
echo

echo "Depositing ${AMOUNT} wei to vault on OP at ${OP_VAULT_ADDRESS}..."
cast send "${OP_VAULT_ADDRESS}" "deposit()" \
  --value "${AMOUNT}" \
  --rpc-url "${OP_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}"

echo "Deposit tx sent."

OP_BALANCE_BEFORE=$(cast balance "${PUBLIC_KEY}" --erc20 "${OP_REBASE_TOKEN_ADDRESS}" --rpc-url "${OP_SEPOLIA_RPC_URL}" || echo "0")
echo "OP token balance: ${OP_BALANCE_BEFORE}"

echo
echo "Deposit vault on Unichain..."
echo

echo "Depositing ${AMOUNT} wei to vault on Unichain at ${UNI_VAULT_ADDRESS}..."
cast send "${UNI_VAULT_ADDRESS}" "deposit()" \
  --value "${AMOUNT}" \
  --rpc-url "${UNI_SEPOLIA_RPC_URL}" \
  --private-key "${PRIVATE_KEY}"

echo "Deposit tx sent."

Unichain_BALANCE_BEFORE=$(cast balance "${PUBLIC_KEY}" --erc20 "${UNI_REBASE_TOKEN_ADDRESS}" --rpc-url "${UNI_SEPOLIA_RPC_URL}" || echo "0")
echo "Unichain token balance: ${Unichain_BALANCE_BEFORE}"

echo
echo "Deposit vault on Soneium..."
echo

echo "Depositing ${AMOUNT} wei to vault on Soneium at ${SONEIUM_VAULT_ADDRESS}..."
cast send "${SONEIUM_VAULT_ADDRESS}" "deposit()" \
  --value "${AMOUNT}" \
  --rpc-url "${SONEIUM_MINATO_RPC_URL}" \
  --private-key "${PRIVATE_KEY}"

echo "Deposit tx sent."

Soneium_BALANCE_BEFORE=$(cast balance "${PUBLIC_KEY}" --erc20 "${SONEIUM_REBASE_TOKEN_ADDRESS}" --rpc-url "${SONEIUM_MINATO_RPC_URL}" || echo "0")
echo "Soneium token balance: ${Soneium_BALANCE_BEFORE}"
