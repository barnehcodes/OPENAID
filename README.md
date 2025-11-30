# 🌍 OpenAID

**Decentralized Humanitarian Aid Platform**

OpenAID is a blockchain-based platform for transparent disaster relief coordination. Built on Scaffold-ETH 2, it implements a three-token system to manage humanitarian aid distribution:

- **DonationToken (ERC20)**: Fungible tokens representing fiat-backed donations
- **InKindNFT (ERC721)**: NFTs representing physical in-kind donations (food, supplies, etc.)
- **OpenAidCore**: Governance contract managing participant registry, crisis coordination, voting, and escrow

⚙️ Built using NextJS, RainbowKit, Hardhat, Wagmi, Viem, and Typescript.

- ✅ **Contract Hot Reload**: Your frontend auto-adapts to your smart contract as you edit it.
- 🪝 **[Custom hooks](https://docs.scaffoldeth.io/hooks/)**: Collection of React hooks wrapper around [wagmi](https://wagmi.sh/) to simplify interactions with smart contracts with typescript autocompletion.
- 🧱 [**Components**](https://docs.scaffoldeth.io/components/): Collection of common web3 components to quickly build your frontend.
- 🔥 **Burner Wallet & Local Faucet**: Quickly test your application with a burner wallet and local faucet.
- 🔐 **Integration with Wallet Providers**: Connect to different wallet providers and interact with the Ethereum network.

![Debug Contracts tab](https://github.com/scaffold-eth/scaffold-eth-2/assets/55535804/b237af0c-5027-4849-a5c1-2e31495cccb1)

## Requirements

Before you begin, you need to install the following tools:

- [Node (>= v20.18.3)](https://nodejs.org/en/download/)
- Yarn ([v1](https://classic.yarnpkg.com/en/docs/install/) or [v2+](https://yarnpkg.com/getting-started/install))
- [Git](https://git-scm.com/downloads)

## Quickstart

To get started with OpenAID, follow the steps below:

1. Install dependencies:

```bash
yarn install
```

2. Run a local network in the first terminal:

```bash
yarn chain
```

This command starts a local Ethereum network using Hardhat. The network runs on your local machine and can be used for testing and development.

3. On a second terminal, deploy the OpenAID contracts:

```bash
yarn deploy
```

This command deploys the three core smart contracts (DonationToken, InKindNFT, OpenAidCore) to the local network. The contracts are located in `packages/hardhat/contracts`.

4. On a third terminal, start your NextJS app:

```bash
yarn start
```

Visit your app on: `http://localhost:3000`. You can interact with the OpenAID smart contracts using the `Debug Contracts` page.

## Testing

For a complete step-by-step testing guide including account setup, participant registration, token minting, crisis declaration, and voting workflows, please refer to **[TESTING_GUIDE.md](./TESTING_GUIDE.md)**.

## Project Structure

- **Smart Contracts** (`packages/hardhat/contracts`):
  - `OpenAidCore.sol`: Central governance contract with role-based access control, participant registry, crisis coordination, and voting system
  - `DonationToken.sol`: ERC20 token for fiat-backed donations
  - `InKindNFT.sol`: ERC721 NFT for tracking physical donations
  
- **Frontend** (`packages/nextjs/app`):
  - Built with Next.js 15 App Router
  - `page.tsx`: Homepage with OpenAID branding
  - `debug/`: Interactive contract debugging interface

- **Deployment** (`packages/hardhat/deploy`):
  - `00_deploy_openaid.ts`: Automated deployment script with correct dependency order

## Key Features

- **Role-Based Access Control**: Supports Donor, Beneficiary, NGO, GO, and Private Company roles
- **Crisis Coordination**: Declare crises and elect coordinators through democratic voting
- **Donation Tracking**: Transparent tracking of both fungible tokens and in-kind donations (NFTs)
- **Escrow Management**: Secure holding of donations until crisis resolution
- **Reputation System**: Built-in reputation tracking with slashing mechanisms
- **NGO Verification**: Admin-controlled verification process for NGO participants

## Smart Contract Testing

Run smart contract tests with:

```bash
yarn hardhat:test
```

## Documentation

- **[TESTING_GUIDE.md](./TESTING_GUIDE.md)**: Complete step-by-step testing workflow
- **[.github/copilot-instructions.md](./.github/copilot-instructions.md)**: Development guidelines and patterns
- **[Scaffold-ETH 2 Docs](https://docs.scaffoldeth.io)**: Learn more about the underlying framework

## Contributing

We welcome contributions to OpenAID! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.