# CCIP-RebaseToken-CrossChain

A cross-chain rebase token implementation using Chainlink’s **CCIP (Cross-Chain Interoperability Protocol)**. This repo demonstrates how to build a rebase (interest-accruing / elastic supply) token that can be bridged across EVM chains using CCIP.

## Motivation & Overview

Modern DeFi often requires assets to move across multiple chains (L1, L2, sidechains) while preserving their economic properties. Rebase tokens introduce complexity (because supply changes over time), and bridging them naively can break invariants or cause loss of value.

This repository aims to implement a rebase token that:

- Accrues yield / interest over time (via rebasing)  
- Can be bridged across chains while preserving correct balances / shares  
- Integrates with Chainlink’s CCIP for secure cross-chain messaging and token transfer  

## Key Concepts

### Rebase Token

A *rebase token* is one whose total supply may change (increase or decrease) periodically (or continuously) to reflect a target metric (e.g. interest, yield). Each holder’s balance scales proportionally.  
Because the supply changes, internal accounting often uses *shares* or *internal units* rather than raw token amounts. (See “rebasing tokens with CCIP” in Chainlink docs)

### CCIP / Cross-Chain Bridge

- **Cross-Chain Bridge**: A system that allows tokens (and/or arbitrary messages) to move from one blockchain to another. Typically involves locking or burning assets on the origin chain, and minting or releasing (or unlocking) them on the destination chain.
- **CCIP (Cross-Chain Interoperability Protocol)** by Chainlink: A protocol that provides messaging, token transfer, and “programmable token transfer” (combining tokens + data) across multiple chains.
- CCIP uses **Routers**, **OnRamps**, **OffRamps**, and **Token Pools** under the hood. When bridging, the CCIP Router interacts with the token pool on the source chain (locking / burning) and the pool on the destination chain (minting / releasing).
- For tokens with special behavior (rebasing, fee-on-transfer, etc.), one must implement **custom Token Pools** with logic in `lockOrBurn` and `releaseOrMint` to correctly preserve “shares” or state across chains.

In short, CCIP handles the cross-chain plumbing; our job is to integrate our token’s rebase logic into CCIP-compatible pools/contracts.

## Architecture & Components

Here is a high-level view of how the repo is organized:

├── src/ # Solidity smart contracts

├── script/ # Deployment / bridging scripts

├── test/ # Tests (unit / cross-chain simulations)

├── lib/ # External dependencies / submodules

├── .github/ # Workflow / CI settings

└── foundry.toml # Foundry config

---

- **RebaseToken.sol** — Implementation of the rebase token (Accrues yield, etc.)  
- **RebaseTokenPool.sol** — A custom CCIP-compatible token pool that implements locking, burning, minting, releasing across chains (with rebase logic)  
- **Vault.sol** — Contracts that interact with RebaseToken to let user depodit and redeem token  
- **Scripts** — helper scripts to deploy, configure, or bridge  
- **Tests** — unit tests and possibly forking / simulated cross-chain bridging  

## Libraries & Tooling

This project uses:

- **Foundry**
  > Smart contract development framework (includes `forge`, `cast`, `anvil`)
  
  Used for:
  - Compiling contracts (`forge build`)
  - Running tests (`forge test`)
  - Deploying & scripting (`forge script`)
  - Local chain simulation (`anvil`)
    
- **Chainlink CCIP Contracts / Interfaces**
  > To interact with Chainlink’s cross-chain infrastructure.

  Used for:
  - Sending and receiving messages between chains  
  - Locking / minting tokens via CCIP Routers  
  - Integrating **Token Pools** for custom token behaviors (like rebasing)
  
- **OpenZeppelin** - for secure, standardized ERC-20 and access control implementations.
  > For secure, standardized ERC-20, math, and access control implementations.

  Used for:
  - `ERC20` and related extensions (base token functionality)  
  - `Ownable` / `AccessControl` for permissioned operations (like rebasing or bridging)  
    
- **Chainlink Local**
  > For simulating CCIP behavior locally during development.
  
  Used for:
  - Running mock CCIP Routers, Token Pools, and LINK tokens  
  - Testing cross-chain message flow without requiring real Chainlink nodes  
  - Validating logic before deploying to testnets (e.g. Sepolia)

## How It Works (Bridge Flow)

1. **User initiates a bridge** via a `sendCrossChain` or similar function  
2. The **RebaseTokenPool** calls CCIP’s Router to send tokens and data to the target chain  
3. CCIP locks or burns tokens on the source chain and transfers message data  
4. On the destination chain, the **RebaseTokenPool** mints or releases tokens  
5. Rebase mechanics are recalculated, ensuring consistent supply ratios across chains

The end result: users can seamlessly move rebase tokens between EVM-compatible networks while preserving yield and balance integrity.

## Author

**Jason Tong**  
*Blockchain Developer | Smart Contract Engineer*

- 🔗 **GitHub:** [JasonTongg](https://github.com/JasonTongg)  
- 💼 **LinkedIn:** [Jason Tong](https://www.linkedin.com/in/jason-tong-42600319a/)  
- 🧠 **Focus:** Solidity · Foundry · EVM · Smart Contracts · Blockchain · Web3
