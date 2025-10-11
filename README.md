# 🛡️ Decentralized Insurance Engine

A fully on-chain insurance protocol built on **Ethereum**, enabling transparent policy creation, premium collection, and claim settlements — **without intermediaries**.

> A trustless, automated, and community-verified alternative to traditional insurance.

---

## 🚀 Overview

Traditional insurance systems are **centralized, opaque, and inefficient**.  
Policyholders must rely on intermediaries for claim verification and settlement, leading to **delays, bias, and fraud**.

This project aims to fix that by building a **decentralized insurance engine** on Ethereum, where:
- Policies are created and managed on-chain  
- Premiums are paid in ERC20 tokens  
- Claims are validated collectively by **on-chain validators**  
- Approved claims are automatically paid via smart contracts  

---

## 🧩 Problem It Solves

Centralized insurance suffers from:
- ❌ Lack of transparency  
- 🕐 Slow claim settlements  
- 🧾 Manual, error-prone verification  
- 💸 High overhead and fraud risk  

Our solution provides:
- ✅ Full transparency through immutable smart contracts  
- ⚡ Instant automated claim settlements  
- 🧠 Community-based validation via decentralized voting  
- 💰 Tokenized premium and payout management  

---

## ⚙️ How It Works

1. **Policy Creation**  
   Users can create new policies directly on-chain, defining coverage amount, premium rate, and duration.

2. **Premium Payment**  
   Premiums are paid periodically using ERC20 tokens.

3. **Claim Submission**  
   When an insured event occurs, users can file a claim with supporting details.

4. **Validator Voting**  
   Validators review the claim and cast votes (`approve` or `reject`) through the smart contract.

5. **Automatic Payout**  
   If a claim passes the majority threshold, the payout is automatically transferred to the claimant’s address.

---

## 🧱 Smart Contract Architecture

### Key Contracts
- `InsuranceEngine.sol` – Core contract for policy, claim, and validator logic  
- `ERC20Token.sol` – Token contract for payments and payouts  
- `ValidatorRegistry.sol` – Handles validator registration and consensus mechanism  

### Tech Stack
| Layer | Technology |
|-------|-------------|
| Blockchain | Ethereum / Sepolia Testnet |
| Language | Solidity (v0.8.x) |
| Frontend | React + Ethers.js |
| Tools | Hardhat / Foundry / Alchemy / CoinDCX |
| Token Standard | ERC20 |

---

## 🧠 Challenges I Ran Into

- Designing complex on-chain logic for policy and claim management  
- Implementing a **validator-based consensus** for claim approvals  
- Managing secure ERC20 token flows for payments and payouts  
- Retrieving nested mappings and structs efficiently  
- Balancing decentralization with usability  
- Extensive debugging and testnet deployment issues  

---

## 🦄 How It Fits the Ethereum Track

This project **embodies Ethereum’s vision** of decentralized, transparent financial systems.  
It leverages Ethereum smart contracts to automate trust and create a **verifiable insurance process**.

- 💡 **Smart Contracts** manage policies, claims, and funds autonomously  
- 💰 **ERC20 integration** for payments and settlements  
- 👥 **On-chain governance** through validator voting  
- 🔗 **Transparency & immutability** ensured by Ethereum  
- 🌐 **Interoperability** with DeFi, Chainlink Oracles, and DAOs  

---

## 📚 What I Learned

- Deep understanding of Solidity struct & mapping design patterns  
- Implementing DAO-style consensus systems  
- Optimizing contract gas usage  
- Frontend ↔ Smart contract integration using Ethers.js  
- Testing, debugging, and deploying contracts on testnets  

---

## 🛠️ Installation & Setup

### Prerequisites
- Node.js ≥ 18  
- Hardhat or Foundry  
- Metamask with Sepolia Testnet  
- Alchemy/Infura API key  

### Steps

```bash
# Clone the repo
git clone https://github.com/yourusername/decentralized-insurance-engine.git

# Enter project directory
cd decentralized-insurance-engine

# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Deploy to testnet
npx hardhat run scripts/deploy.js --network sepolia

# Start frontend
npm run dev
