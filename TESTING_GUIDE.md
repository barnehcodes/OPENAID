# OpenAID Testing Guide

Complete step-by-step guide for testing the OpenAID protocol on the Scaffold-ETH debug interface.

## 📋 Prerequisites

### Account Mapping
| Role | Address | MetaMask Account |
|------|---------|------------------|
| **Admin/Social** | `0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266` | Account #0 |
| **Donor** | `0x70997970c51812dc3a010c7d01b50e0d17dc79c8` | Account #1 |
| **GO** | `0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC` | Account #2 |
| **NGO** | `0x90F79bf6EB2c4f870365E785982E1f101E93b906` | Account #3 |
| **Beneficiary** | `0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65` | Account #4 |

### Key Values
- `donationCap` = 100 tokens (100000000000000000000 wei)
- Donor threshold: 100 tokens
- NGO threshold: 1000 tokens (10x)
- GO threshold: 1500 tokens (15x)
- RoleType enum: Unknown=0, Donor=1, Beneficiary=2, NGO=3, GO=4, PrivateCompany=5

---

## 🎯 Phase 1: Initial Setup

**Current Account:** Admin (Account #0 - `0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266`)

Visit: `http://localhost:3000/debug`

### ✅ Step 1.1: Grant NGO_VERIFIER Role
- Contract: **OpenAidCore**
- Function: `setNGOVerifier`
- Parameters:
  - `who`: `0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266`
- Click **Send** 💸

### ✅ Step 1.2: Grant MINTER_ROLE to OpenAidCore on InKindNFT
- Contract: **InKindNFT** (use dropdown to switch)
- Function: `grantRole`
- Parameters:
  - `role`: `0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6`
  - `account`: `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`
- Click **Send** 💸

> ✅ **Phase 1 Complete!** Admin setup done.

---

## 👥 Phase 2: Register All Participants

### ✅ Step 2.1: Register Donor
- **Switch to Account #1** in MetaMask (`0x70997970c51812dc3a010c7d01b50e0d17dc79c8`)
- Contract: **OpenAidCore**
- Function: `registerParticipant`
- Parameters:
  - `role`: `1` (Donor)
- Click **Send** 💸

### ✅ Step 2.2: Register GO
- **Switch to Account #2** in MetaMask (`0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC`)
- Contract: **OpenAidCore**
- Function: `registerParticipant`
- Parameters:
  - `role`: `4` (GO)
- Click **Send** 💸

### ✅ Step 2.3: Register NGO
- **Switch to Account #3** in MetaMask (`0x90F79bf6EB2c4f870365E785982E1f101E93b906`)
- Contract: **OpenAidCore**
- Function: `registerParticipant`
- Parameters:
  - `role`: `3` (NGO)
- Click **Send** 💸

### ✅ Step 2.4: Register Beneficiary
- **Switch to Account #4** in MetaMask (`0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65`)
- Contract: **OpenAidCore**
- Function: `registerParticipant`
- Parameters:
  - `role`: `2` (Beneficiary)
- Click **Send** 💸

### ✅ Step 2.5: Verify NGO
- **Switch back to Account #0** in MetaMask (Admin)
- Contract: **OpenAidCore**
- Function: `verifyNGO`
- Parameters:
  - `ngo`: `0x90F79bf6EB2c4f870365E785982E1f101E93b906`
- Click **Send** 💸

> ✅ **Phase 2 Complete!** All participants registered.

---

## 💰 Phase 3: Mint & Donate Tokens

**Current Account:** Admin (Account #0)

### ✅ Step 3.1: Mint Tokens to Donor
- Contract: **DonationToken** (switch using dropdown)
- Function: `mint`
- Parameters:
  - `to`: `0x70997970c51812dc3a010c7d01b50e0d17dc79c8`
  - `amount`: `2000000000000000000000` (2000 tokens)
- Click **Send** 💸

### ✅ Step 3.2: Mint Tokens to GO
- Contract: **DonationToken**
- Function: `mint`
- Parameters:
  - `to`: `0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC`
  - `amount`: `2000000000000000000000` (2000 tokens)
- Click **Send** 💸

### ✅ Step 3.3: Mint Tokens to NGO
- Contract: **DonationToken**
- Function: `mint`
- Parameters:
  - `to`: `0x90F79bf6EB2c4f870365E785982E1f101E93b906`
  - `amount`: `1500000000000000000000` (1500 tokens)
- Click **Send** 💸

---

### ✅ Step 3.4: Donor Approves OpenAidCore
- **Switch to Account #1** in MetaMask (Donor)
- Contract: **DonationToken**
- Function: `approve`
- Parameters:
  - `spender`: `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`
  - `value`: `2000000000000000000000`
- Click **Send** 💸

### ✅ Step 3.5: Donor Donates
- Contract: **OpenAidCore** (switch using dropdown)
- Function: `donateFT`
- Parameters:
  - `beneficiary`: `0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65`
  - `amount`: `200000000000000000000` (200 tokens - meets donor threshold)
- Click **Send** 💸

---

### ✅ Step 3.6: GO Approves OpenAidCore
- **Switch to Account #2** in MetaMask (GO)
- Contract: **DonationToken**
- Function: `approve`
- Parameters:
  - `spender`: `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`
  - `value`: `2000000000000000000000`
- Click **Send** 💸

### ✅ Step 3.7: GO Donates
- Contract: **OpenAidCore**
- Function: `donateFT`
- Parameters:
  - `beneficiary`: `0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65`
  - `amount`: `1500000000000000000000` (1500 tokens - meets GO threshold)
- Click **Send** 💸

---

### ✅ Step 3.8: NGO Approves OpenAidCore
- **Switch to Account #3** in MetaMask (NGO)
- Contract: **DonationToken**
- Function: `approve`
- Parameters:
  - `spender`: `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`
  - `value`: `1500000000000000000000`
- Click **Send** 💸

### ✅ Step 3.9: NGO Donates
- Contract: **OpenAidCore**
- Function: `donateFT`
- Parameters:
  - `beneficiary`: `0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65`
  - `amount`: `1000000000000000000000` (1000 tokens - meets NGO threshold)
- Click **Send** 💸

> ✅ **Phase 3 Complete!** All participants have donated and met voting thresholds.

---

## 🚨 Phase 4: Crisis & Voting

### ✅ Step 4.1: Declare Crisis
- **Switch to Account #0** in MetaMask (Admin/Social)
- Contract: **OpenAidCore**
- Function: `declareCrisis`
- Parameters:
  - `votingDuration`: `3600` (1 hour = 3600 seconds)
- Click **Send** 💸
- **Note:** Crisis ID = 1 is created

### ✅ Step 4.2: GO Registers as Candidate
- **Switch to Account #2** in MetaMask (GO)
- Contract: **OpenAidCore**
- Function: `registerCandidate`
- Parameters:
  - `crisisId`: `1`
- Click **Send** 💸

### ✅ Step 4.3: NGO Registers as Candidate
- **Switch to Account #3** in MetaMask (NGO)
- Contract: **OpenAidCore**
- Function: `registerCandidate`
- Parameters:
  - `crisisId`: `1`
- Click **Send** 💸

### ✅ Step 4.4: Donor Casts Vote
- **Switch to Account #1** in MetaMask (Donor)
- Contract: **OpenAidCore**
- Function: `castVote`
- Parameters:
  - `crisisId`: `1`
  - `candidate`: `0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC` (GO) OR `0x90F79bf6EB2c4f870365E785982E1f101E93b906` (NGO)
- Click **Send** 💸

### ✅ Step 4.5: Finalize Voting
- **Switch to Account #0** in MetaMask (Admin/Social)
- Contract: **OpenAidCore**
- Function: `finalizeBySocialAuthority`
- Parameters:
  - `crisisId`: `1`
  - `coordinator`: `0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC` (GO) OR `0x90F79bf6EB2c4f870365E785982E1f101E93b906` (NGO)
- Click **Send** 💸

> ✅ **Phase 4 Complete!** Crisis coordinator elected.

---

## ✅ Verification Checks

Use the **Read** section on **OpenAidCore** to verify:

### Check Participant Registration
- Function: `registry`
- Input: Any participant address
- Should show: `role`, `exists: true`, `totalDonated`, `verified` status

### Check Crisis Status
- Function: `crises`
- Input: `1`
- Should show: `active: false`, `finalized: true`, `coordinator` address set

### Check Escrow Balance
- Function: `ftEscrow`
- Input: `0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65` (Beneficiary)
- Should show: `2700000000000000000000` (2700 tokens total from all donations)

### Check Token Balances
- Contract: **DonationToken**
- Function: `balanceOf`
- Check each participant's remaining balance

---

## 🔄 How to Reset Testing

### Option 1: Quick Reset (Recommended)
1. **Stop the blockchain:**
   - In Terminal 1 (running `yarn chain`), press `Ctrl+C`

2. **Restart blockchain:**
   ```bash
   yarn chain
   ```

3. **Redeploy contracts (new terminal):**
   ```bash
   yarn deploy
   ```

4. **Reset MetaMask:**
   - Open MetaMask
   - Settings → Advanced → "Clear activity tab data"
   - This resets nonce counters

5. **Refresh browser:**
   - Go to `http://localhost:3000/debug`
   - Hard refresh: `Ctrl+Shift+R` (Linux) or `Cmd+Shift+R` (Mac)

### Option 2: Full Clean Reset
```bash
# Terminal 1: Stop chain (Ctrl+C), then:
cd ~/Desktop/OPenAID3/my-openaid
rm -rf packages/hardhat/deployments/localhost
rm -rf packages/hardhat/cache
yarn chain

# Terminal 2: Wait for chain to start, then:
yarn deploy

# Terminal 3:
yarn start
```

Then:
- Reset MetaMask (Settings → Advanced → Clear activity tab data)
- Refresh browser at `http://localhost:3000/debug`

---

## 🐛 Common Issues & Solutions

### Issue: "Internal JSON-RPC error"
**Solution:** Blockchain not running. Start with `yarn chain`

### Issue: "Nonce too high" error
**Solution:** Reset MetaMask account (Settings → Advanced → Clear activity tab data)

### Issue: Contract functions return "0x"
**Solution:** Contracts not deployed. Run `yarn deploy`

### Issue: "Already registered" error
**Solution:** Need to reset blockchain (see Reset Testing above)

### Issue: "Token transfer failed"
**Solution:** Check if you approved OpenAidCore to spend tokens first

### Issue: "Donation threshold not met"
**Solution:** 
- Donor needs 100 tokens donated
- NGO needs 1000 tokens donated
- GO needs 1500 tokens donated

---

## 📝 Notes

- Always use **18 decimals** for token amounts (add 18 zeros)
- Example: 100 tokens = `100000000000000000000`
- Admin (Account #0) has MINTER_ROLE by default
- Crisis IDs start at 1, not 0
- Voting duration is in seconds (3600 = 1 hour)
- You must approve tokens before donating
- NGOs must be verified before they can register as candidates

---

## 🎯 Quick Reference

**Network:** Localhost (Chain ID: 31337, Port: 8545)

**Contract Addresses (after deployment):**
- DonationToken: `0x5FbDB2315678afecb367f032d93F642f64180aa3`
- InKindNFT: `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`
- OpenAidCore: `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`

**MINTER_ROLE:** `0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6`

---

Good luck testing! 🚀
