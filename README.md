# MoWallet - Simple Token Wallet

A modern, secure ERC20 token wallet built with Foundry and Next.js. This project demonstrates a full-stack dApp implementation with smart contracts and a stylish frontend.

## Features

- 🔒 Secure ERC20 token deposits and withdrawals
- 💰 Accurate token balance tracking
- 📝 Comprehensive event logging
- 🎨 Modern UI built with Next.js, Wagmi, and RainbowKit
- ✅ Thoroughly tested with Foundry

## Tech Stack

- **Smart Contracts**: Solidity + Foundry
- **Frontend**: Next.js + Wagmi + RainbowKit
- **Testing**: Foundry Test Suite
- **Security**: OpenZeppelin Contracts

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- Foundry
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Digital8882/mowall.git
cd mowall
```

2. Install dependencies:
```bash
# Install Foundry dependencies
cd packages/foundry
forge install
cd ../..

# Install frontend dependencies
cd packages/nextjs
yarn install
cd ../..
```

### Running Tests

```bash
cd packages/foundry
forge test -vv
```

### Local Development

1. Start a local Ethereum node:
```bash
anvil
```

2. Deploy the contracts:
```bash
cd packages/foundry
forge create SimpleTokenWallet --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

3. Start the frontend:
```bash
cd packages/nextjs
yarn dev
```

Visit `http://localhost:3000` to interact with the application.

## Smart Contract Architecture

The project consists of two main contracts:

1. `SimpleTokenWallet.sol`: The main wallet contract that handles token deposits and withdrawals
2. `TestToken.sol`: A simple ERC20 token for testing purposes

### Key Functions

- `deposit(address token, uint256 amount)`: Deposit ERC20 tokens
- `withdraw(address token, uint256 amount)`: Withdraw deposited tokens
- `balanceOf(address token)`: Check token balance

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

