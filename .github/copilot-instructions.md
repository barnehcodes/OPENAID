# OpenAID - Copilot Instructions

## Project Overview
OpenAID is a decentralized humanitarian aid platform built on Scaffold-ETH 2. It implements a three-token system for transparent disaster relief coordination:
- **DonationToken (ERC20)**: Fungible tokens representing fiat-backed donations
- **InKindNFT (ERC721)**: NFTs representing physical in-kind donations (food, supplies, etc.)
- **OpenAidCore**: Governance contract managing participant registry, crisis coordination, voting, and escrow

## Architecture

### Smart Contract System (packages/hardhat/contracts/)
Three interconnected contracts form the core protocol:

1. **OpenAidCore.sol**: Central governance contract
   - Role-based access control (SOCIAL_ROLE, EXCHANGE_ROLE, NGO_VERIFIER)
   - Participant registry with 5 role types: Donor, Beneficiary, NGO, GO, PrivateCompany
   - Crisis declaration and coordinator voting system
   - Escrow management for FT donations
   - Reputation system with slashing mechanisms
   - Donation thresholds for coordinator candidates (NGOs: 10x donationCap, GOs: 15x donationCap)

2. **DonationToken.sol**: Minimal ERC20 with MINTER_ROLE for OpenAidCore
3. **InKindNFT.sol**: ERC721 with MINTER_ROLE for tracking physical donations

**Critical deployment order** (see `packages/hardhat/deploy/00_deploy_openaid.ts`):
1. Deploy DonationToken with deployer as initialMinter
2. Deploy InKindNFT with deployer as initialMinter  
3. Deploy OpenAidCore with both token addresses + socialAdmin

### Frontend (packages/nextjs/)
Next.js 15 app using App Router (not Pages Router) with:
- RainbowKit for wallet connections
- Wagmi/Viem for blockchain interactions
- TypeScript with auto-generated ABIs from contracts

## Development Workflow

### Essential Commands
```bash
# Terminal 1: Start local blockchain
yarn chain

# Terminal 2: Deploy contracts (auto-generates TypeScript ABIs)
yarn deploy

# Terminal 3: Start frontend dev server
yarn start
```

Visit `http://localhost:3000/debug` to interact with contracts via auto-generated UI.

### Contract Interactions
**ALWAYS use Scaffold-ETH hooks** - never write raw wagmi/viem calls:

**Reading contract state:**
```typescript
import { useScaffoldReadContract } from "~~/hooks/scaffold-eth";

const { data: participant } = useScaffoldReadContract({
  contractName: "OpenAidCore",
  functionName: "registry",
  args: [address],
});
```

**Writing to contracts:**
```typescript
import { useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

const { writeContractAsync } = useScaffoldWriteContract({
  contractName: "OpenAidCore"
});

await writeContractAsync({
  functionName: "registerParticipant",
  args: [roleType],
});
```

**Listening to events:**
```typescript
import { useScaffoldEventHistory } from "~~/hooks/scaffold-eth";

const { data: events } = useScaffoldEventHistory({
  contractName: "OpenAidCore",
  eventName: "CrisisDeclared",
  watch: true,
});
```

### Contract Type Generation
- Editing `.sol` files auto-triggers ABI regeneration
- ABIs appear in `packages/nextjs/contracts/deployedContracts.ts`
- TypeScript types in `packages/hardhat/typechain-types/`
- Frontend hot-reloads when contracts change

## Project-Specific Conventions

### Solidity Patterns
- All three contracts use OpenZeppelin's AccessControl for permissions
- InKindNFT requires `supportsInterface` override for ERC721+AccessControl multiple inheritance
- Crisis IDs start at 1 (not 0): `crisisCount++` before creating crisis
- Candidate registration enforces donation thresholds via `totalDonated` field

### Testing
Run contract tests: `yarn hardhat:test`
Tests located in `packages/hardhat/test/`

### Network Configuration
- Default network: `localhost` (see `packages/hardhat/hardhat.config.ts`)
- Frontend targets: configured in `packages/nextjs/scaffold.config.ts`
- Current setup: `targetNetworks: [chains.hardhat]` with burner wallet only

### Key File Locations
- Contract deployment scripts: `packages/hardhat/deploy/`
- Contract ABIs (auto-gen): `packages/nextjs/contracts/deployedContracts.ts`
- Scaffold hooks: `packages/nextjs/hooks/scaffold-eth/`
- Frontend entry: `packages/nextjs/app/page.tsx`

## Common Gotchas
- Never edit `deployedContracts.ts` manually - it's auto-generated
- Use absolute imports with `~~/` prefix in Next.js code
- Scaffold hooks require contract names to exactly match deployed contract names
- Crisis voting requires participants to meet donation thresholds BEFORE registering as candidates
- Role verification (NGOs) is a two-step process: register, then admin verifies

## Testing the Protocol (Debug Interface)

### Test Accounts Setup
Use these Hardhat accounts for role-based testing:

| Role | Address | MetaMask Account |
|------|---------|------------------|
| **Admin/Social** | `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` | Account #0 |
| **Donor** | `0x70997970C51812dc3A010C7d01b50e0d17dc79C8` | Account #1 |
| **NGO** | `0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC` | Account #2 |
| **GO** | `0x90F79bf6EB2c4f870365E785982E1f101E93b906` | Account #3 |
| **Beneficiary** | `0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65` | Account #4 |

### Complete Testing Workflow

Visit `http://localhost:3000/debug` and follow this sequence:

#### Phase 1: Setup & Registration
1. **Switch to Account #0 (Admin)**
   - Grant MINTER_ROLE on DonationToken to Account #1 (Donor)
   - Grant MINTER_ROLE on InKindNFT to OpenAidCore contract
   - Grant NGO_VERIFIER role to yourself on OpenAidCore

2. **Register Participants** (switch accounts in MetaMask):
   - Account #1 → `OpenAidCore.registerParticipant(1)` (Donor = 1)
   - Account #2 → `OpenAidCore.registerParticipant(3)` (NGO = 3)
   - Account #3 → `OpenAidCore.registerParticipant(4)` (GO = 4)
   - Account #4 → `OpenAidCore.registerParticipant(2)` (Beneficiary = 2)

3. **Verify NGO** (Account #0):
   - `OpenAidCore.verifyNGO(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC)`

#### Phase 2: Mint & Donate Tokens
1. **Switch to Account #1 (Donor)**
   - `DonationToken.mint(your_address, 2000000000000000000000)` (2000 tokens)
   
2. **Approve OpenAidCore to spend tokens**:
   - `DonationToken.approve(OpenAidCore_address, 2000000000000000000000)`

3. **Donate to meet thresholds**:
   - `OpenAidCore.donateFT(beneficiary_address, 200000000000000000000)` (200 tokens for donor threshold)
   
4. **Mint tokens for NGO/GO** (Account #0 as Admin):
   - Mint 1500 tokens to Account #2 (NGO needs 1000 for threshold)
   - Mint 2000 tokens to Account #3 (GO needs 1500 for threshold)

5. **NGO/GO donate** (switch to each account):
   - Approve OpenAidCore first
   - Donate required amounts to meet voting thresholds

#### Phase 3: Crisis & Voting
1. **Declare Crisis** (Account #0 as Social):
   - `OpenAidCore.declareCrisis(3600)` (1 hour voting period)
   - Note the crisis ID (should be 1)

2. **Register Candidates**:
   - Account #2 (NGO) → `OpenAidCore.registerCandidate(1)`
   - Account #3 (GO) → `OpenAidCore.registerCandidate(1)`

3. **Cast Votes** (switch between eligible accounts):
   - Account #1 (Donor) → `OpenAidCore.castVote(1, ngo_or_go_address)`
   - Account #4 (Beneficiary - must be verified first) → similar

4. **Finalize Voting** (after time passes or as Social):
   - `OpenAidCore.finalizeVoting(1)` OR
   - `OpenAidCore.finalizeBySocialAuthority(1, winner_address)`

#### Phase 4: Test Escrow & Redemption
1. **Setup Exchange Role** (Account #0):
   - `OpenAidCore.setExchange(your_address)`

2. **Redeem FT** (as Exchange):
   - `OpenAidCore.redeemFT(beneficiary_address, amount)`

3. **Test In-Kind Donations**:
   - `OpenAidCore.commitInKind("Food Package - 50kg rice")` (as registered donor)
   - `OpenAidCore.redeemNFT(token_id, beneficiary_address)` (as Exchange)

### Key Values for Testing
- `donationCap = 100 ether` (100 tokens with 18 decimals)
- Donor threshold: 100 tokens
- NGO threshold: 1000 tokens (10x)
- GO threshold: 1500 tokens (15x)
- RoleType enum: Unknown=0, Donor=1, Beneficiary=2, NGO=3, GO=4, PrivateCompany=5

## Known Issues

### SWC Lockfile Patching Warning
If using Yarn v3+ and seeing "Failed to patch lockfile" errors when running `yarn start`:
- **The app still works** - this is a cosmetic warning from Next.js 15's SWC patching
- Quick fix: Downgrade to Yarn Classic v1.22.x (remove `.yarn/` and `.yarnrc.yml`, reinstall with `yarn install`)
- Or ignore the warning - it doesn't affect functionality
