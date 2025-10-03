# Local Testing with Anvil

This guide explains how to test the Insurance Claim Decentralized contract locally using Anvil.

## Prerequisites

Make sure you have Foundry installed. If not, install it with:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## Setting up Anvil

1. Start Anvil in a new terminal:
```bash
anvil
```

This will start a local Ethereum node with 10 test accounts, each with 10,000 ETH. Note down the RPC URL and private keys.

## Deploying Contracts

1. In a new terminal, deploy the contracts:
```bash
cd /home/amlan/solidity/Insurance-Claim-Decentralized
forge script script/DeployEngine.s.sol:DeployEngine --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

Replace the private key with the first one from Anvil output.

## Interacting with Contracts

After deployment, you'll get the addresses of the deployed contracts. You can interact with them using cast:

1. Set environment variables for easier interaction:
```bash
export TOKEN_ADDRESS=<TestToken_Address_From_Deployment>
export ENGINE_ADDRESS=<Engine_Address_From_Deployment>
export RPC_URL=http://127.0.0.1:8545
```

2. Check token balance of an account:
```bash
cast call $TOKEN_ADDRESS "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url $RPC_URL
```

3. Approve tokens for premium payment:
```bash
cast send $TOKEN_ADDRESS "approve(address,uint256)" $ENGINE_ADDRESS 100000000000000000000 --rpc-url $RPC_URL --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

4. Create a policy template (as admin):
```bash
cast send $ENGINE_ADDRESS "createPolicyTemplate(uint256,uint256,uint256,uint256,string,bool,uint256)" 1 5000000000000000000000 1 31536001 "health" true 100000000000000000000 --rpc-url $RPC_URL --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

5. Buy a policy (as policy holder):
```bash
cast send $ENGINE_ADDRESS "buyPolicy(uint256)" 1 --rpc-url $RPC_URL --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

## Token Address for Testing

When testing locally with Anvil, you can deploy the TestToken contract as shown in the deployment script. The TestToken contract is a simple ERC20 token with the following features:

- Name: TestToken (TST)
- Initial supply: 1,000,000 tokens
- Decimals: 18 (standard)

For local testing, you can use any of the test accounts provided by Anvil as the token address after deploying the TestToken contract.

## Running Tests

To run the existing tests:
```bash
forge test -vvv
```

This will run all the tests in the test directory and show detailed output.