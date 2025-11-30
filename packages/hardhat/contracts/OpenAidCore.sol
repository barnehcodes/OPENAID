// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
 * OpenAidCore.sol
 * Core protocol: registry, crises, voting, escrow, reputation, misconduct voting.
 *
 * Design rationale:
 * - Single authoritative contract for governance and rules.
 * - Delegates token operations to DonationToken and NFT minting to InKindNFT.
 * - Social layer authority (off-chain or DAO multisig) is modeled as a role (SOCIAL_ROLE).
 *
 * This PoC implements simplified versions of:
 * - Registering participants
 * - Verifying NGOs (by SOCIAL_ROLE)
 * - Triggering crises & starting coordinator voting
 * - Voting rules (PoC: donation thresholds enforced off-chain or via token balance)
 * - Collecting FT donations into escrow for beneficiaries
 * - Minting NFTs for in-kind donations (via InKindNFT)
 * - Reputation & slashing mechanisms
 *
 * This follows the architecture / goals described in the paper. 
 */

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./DonationToken.sol";
import "./InKindNFT.sol";

//We integrate the FT and NFT contracts

contract OpenAidCore is AccessControl {
    bytes32 public constant SOCIAL_ROLE = keccak256("SOCIAL_ROLE"); // off-chain authority
    //
    bytes32 public constant EXCHANGE_ROLE = keccak256("EXCHANGE_ROLE"); // entities that can redeem FT
    bytes32 public constant NGO_VERIFIER = keccak256("NGO_VERIFIER"); // can mark NGOs verified

    DonationToken public donationToken;
    InKindNFT public inKindNft;
    //init 

    enum RoleType { Unknown, Donor, Beneficiary, NGO, GO, PrivateCompany }
    //maybe : PriorityBeneficiary

    struct Participant {
        RoleType role;
        bool exists;
        bool verified; // for NGOs, beneficiaries (for event)
        uint256 reputation; // for GOs/NGOs
        uint256 totalDonated;
    }
    mapping(uint256 => address[]) public candidateList;
    mapping(address => Participant) public registry;
    mapping(uint256 => mapping(address => uint256)) public candidateDonation;
    // Escrow: beneficiary => token amount held
    mapping(address => uint256) public ftEscrow;

    // In-kind inventory: nftId => status (0 = pending / held, 1 = redeemed)
    mapping(uint256 => uint8) public nftStatus;

    // Crisis and voting
    struct Crisis {
        bool active;
        uint256 voteEnd;
        address coordinator; // chosen after voting
        uint256 collected; // total collected during voting
        bool finalized;
    }
    mapping(uint256 => Crisis) public crises;
    uint256 public crisisCount;

    /**
    First crisis → ID = 1

    Second crisis → ID = 2

    Third crisis → ID = 3
    **/

    // Voting state per crisis: candidate => votes
    mapping(uint256 => mapping(address => uint256)) public votesFor;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Reputation slashing mechanism
    event Registered(address indexed who, RoleType role);
    event NGOVerified(address indexed ngo);
    event CrisisDeclared(uint256 indexed crisisId, uint256 voteEnd);
    event CandidateRegistered(uint256 indexed crisisId, address indexed candidate);
    event VoteCast(uint256 indexed crisisId, address indexed voter, address indexed candidate);
    event VotingFinalized(uint256 indexed crisisId, address coordinator);
    event FTDonated(address indexed donor, address indexed beneficiary, uint256 amount);
    event InKindCommitted(address indexed donor, uint256 nftId);
    event FTRedeemed(address indexed beneficiary, uint256 amount);
    event ReputationSlashed(address indexed entity, uint256 newReputation);

    constructor(address tokenAddr, address nftAddr, address socialAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SOCIAL_ROLE, socialAdmin);
        donationToken = DonationToken(tokenAddr);
        inKindNft = InKindNFT(nftAddr);
    }

    // --- Registration ---
    function registerParticipant(RoleType role) external {
        require(role != RoleType.Unknown, "Invalid role");
        // to be revisted <---------------
        require(!registry[msg.sender].exists, "Already registered");
        //check if already particiapnt exists 
        registry[msg.sender] = Participant({
            role: role,
            exists: true,
            verified: false,
            reputation: (role == RoleType.GO || role == RoleType.NGO) ? 100 : 0,

            totalDonated: 0
        });
        // why 0 instead of no reputation => no concept of skippin => simplicity 

        emit Registered(msg.sender, role);
        // when registered emit it 
    
    }

    // NGOs must be verified by an off-chain process and the SOCIAL_ROLE
    function verifyNGO(address ngo) external onlyRole(NGO_VERIFIER) {
        require(registry[ngo].exists, "Not registered");
        require(registry[ngo].role == RoleType.NGO, "Not NGO");
        registry[ngo].verified = true;
        emit NGOVerified(ngo);
    }

    // --- Crises & Voting ---
    // Social layer (off-chain) declares crisis and sets voting duration.
    function declareCrisis(uint256 votingDuration) external onlyRole(SOCIAL_ROLE) returns (uint256) {
        crisisCount++;
        crises[crisisCount] = Crisis({
            active: true,
            voteEnd: block.timestamp + votingDuration,
            coordinator: address(0),
            collected: 0,
            finalized: false
        });
        emit CrisisDeclared(crisisCount, crises[crisisCount].voteEnd);
        return crisisCount;
    }

    // Entities (GOs/NGOs) register as candidate for a crisis
   function registerCandidate(uint256 crisisId) external {
    Crisis storage c = crises[crisisId];

    // --- 1. Crisis must be active & in voting phase ---
    require(c.active, "Crisis not active");
    require(block.timestamp <= c.voteEnd, "Voting already ended");

    // --- 2. Sender must be registered ---
    Participant storage participant = registry[msg.sender];
    require(participant.exists, "Not registered");

    // --- 3. Only NGOs, GOs can run ---
    require(
        participant.role == RoleType.NGO ||
        participant.role == RoleType.GO,
        "Role not eligible to run"
    );

    // --- 4. Enforce donation threshold based on role ---
    if (participant.role == RoleType.NGO) {
        // NGOs → donationCap * 10
        require(
            participant.totalDonated >= donationCap * 10,
            "NGO: donation threshold not met"
        );
    }
    else if (
        participant.role == RoleType.GO 
    ) {
        // GOs → donationCap * 15
        require(
            participant.totalDonated >= donationCap * 15,
            "GO: donation threshold not met"
        );
    }
    // --- 5. Prevent duplicate registration ---
    for (uint256 i = 0; i < candidateList[crisisId].length; i++) {
        require(candidateList[crisisId][i] != msg.sender, "Already a candidate");
    }

    // --- 6. Add to candidate list ---
    candidateList[crisisId].push(msg.sender);

    // --- Snapshot their donation amount at registration time ---
    candidateDonation[crisisId][msg.sender] = participant.totalDonated;
    // ---  Register candidate ---
    emit CandidateRegistered(crisisId, msg.sender);
}


    // Base donation requirement (example: 100 tokens = 100 DH)
    uint256 public donationCap = 100 ether;

    // Cast a vote for a crisis coordinator
    function castVote(uint256 crisisId, address candidate) external {
        Crisis storage c = crises[crisisId];

        // --- 1. Crisis must be active and voting still open ---
        require(c.active, "Crisis not active");
        require(block.timestamp <= c.voteEnd, "Voting period ended");

        // --- 2. Voter must be registered ---
        Participant storage voter = registry[msg.sender];
        require(voter.exists, "Voter not registered");

        // --- 3. Candidate must be registered ---
        require(registry[candidate].exists, "Candidate not registered");

        // --- 4. Prevent double voting ---
        require(!hasVoted[crisisId][msg.sender], "Already voted");

        // --- 5. Voting eligibility logic ---
        if (voter.role == RoleType.Donor) {
            // Donors must meet donation cap
            require(
                voter.totalDonated >= donationCap,
                "Donor: donation threshold not met"
            );
        }
        else if (voter.role == RoleType.NGO) {
            // NGOs must donate donationCap * 10
            require(
                voter.totalDonated >= donationCap * 10,
                "NGO: donation threshold not met"
            );
        }
        else if (voter.role == RoleType.GO || voter.role == RoleType.PrivateCompany) {
            // GOs and Companies must donate donationCap * 15
            require(
                voter.totalDonated >= donationCap * 15,
                "GO/Company: donation threshold not met"
            );
        }
        else if (voter.role == RoleType.Beneficiary) {
            // Beneficiaries must be verified for this crisis
            require(voter.verified, "Beneficiary not verified");
        }
        else {
            revert("Role cannot vote");
        }

        // --- 6. Record vote ---
        votesFor[crisisId][candidate] += 1;
        hasVoted[crisisId][msg.sender] = true;

        emit VoteCast(crisisId, msg.sender, candidate);
    }


    

    // Finalize vote: picks candidate with most votes and transfer collected voting funds to coordinator
    function finalizeVoting(uint256 crisisId) external {
        Crisis storage c = crises[crisisId];

        require(c.active, "Crisis not active");
        require(block.timestamp > c.voteEnd, "Voting still ongoing");
        require(!c.finalized, "Already finalized");

        address[] storage candidates = candidateList[crisisId];
        require(candidates.length > 0, "No candidates");

        address winner = candidates[0];
        // innit
        uint256 highestVotes = votesFor[crisisId][winner];
        uint256 highestDonation = candidateDonation[crisisId][winner];

        // --- 1. Loop through candidates to find the winner ---
        for (uint256 i = 1; i < candidates.length; i++) {
            address candidate = candidates[i];

            uint256 candidateVotes = votesFor[crisisId][candidate];
            uint256 candidateDonations = candidateDonation[crisisId][candidate];

            // Check who has more votes
            if (candidateVotes > highestVotes) {
                winner = candidate;
                highestVotes = candidateVotes;
                highestDonation = candidateDonations;
            } 
            // If votes are equal → tie-break by donations
            else if (candidateVotes == highestVotes) {
                if (candidateDonations > highestDonation) {
                    winner = candidate;
                    highestDonation = candidateDonations;
                }
            }
        }

        // --- 2. Set winner as coordinator ---
        c.coordinator = winner;
        c.finalized = true;
        c.active = false;

        // --- 3. Optional: send crisis collected tokens to coordinator ---
        if (c.collected > 0) {
            donationToken.transfer(winner, c.collected);
        }

        emit VotingFinalized(crisisId, winner);
    }

    // finalize voting by Social authority (trusted actor that can set coordinator after verifying votes off-chain / on-chain)
    function finalizeBySocialAuthority(uint256 crisisId, address coordinator) external onlyRole(SOCIAL_ROLE) {
        Crisis storage c = crises[crisisId];
        require(c.active && block.timestamp >= c.voteEnd, "Voting not ended");
        require(!c.finalized, "Already finalized");
        require(registry[coordinator].exists, "Coordinator not registered");
        c.coordinator = coordinator;
        c.finalized = true;
        c.active = false;
        // Transfer collected funds to coordinator (collected stored in c.collected)
        if (c.collected > 0) {
            donationToken.transfer(coordinator, c.collected);
        }
        emit VotingFinalized(crisisId, coordinator);
    }

    // --- Donations ---
    // Donor must approve this contract for donationToken before calling donateFT.
    function donateFT(address beneficiary, uint256 amount) external {
        require(registry[msg.sender].exists, "Donor not registered");
        require(amount > 0, "Zero amount");
        // transfer from donor to contract as escrow
        bool ok = donationToken.transferFrom(msg.sender, address(this), amount);
        require(ok, "Token transfer failed");
        ftEscrow[beneficiary] += amount;
        registry[msg.sender].totalDonated += amount;
        // track total collected for active crisis(es) — for PoC, not tied automatically to crisis; social layer can associate later
        emit FTDonated(msg.sender, beneficiary, amount);
    }

    // Coordinator or exchange can redeem funds to beneficiary (simulate exchange center)
    function redeemFT(address beneficiary, uint256 amount) external onlyRole(EXCHANGE_ROLE) {
        require(ftEscrow[beneficiary] >= amount, "Not enough escrow");
        ftEscrow[beneficiary] -= amount;
        donationToken.transfer(beneficiary, amount);
        emit FTRedeemed(beneficiary, amount);
    }

    // In-kind commit: donor calls to instruct off-chain delivery; contract mints NFT to the contract (inventory)
    // Donor must have MINTER_ROLE in InKindNFT (in PoC OpenAidCore will be minter)
    function commitInKind(string calldata meta) external {
        require(registry[msg.sender].exists, "Donor not registered");
        uint256 id = inKindNft.mintTo(address(this), meta);
        nftStatus[id] = 0; // pending / held
        emit InKindCommitted(msg.sender, id);
    }

    // When beneficiary redeems NFT, EXCHANGE_ROLE transfers NFT to beneficiary and marks redeemed
    function redeemNFT(uint256 nftId, address to) external onlyRole(EXCHANGE_ROLE) {
        require(nftStatus[nftId] == 0, "Already redeemed");
        inKindNft.safeTransferFrom(address(this), to, nftId);
        nftStatus[nftId] = 1;
    }

    // --- Reputation & Slashing ---
    // Anyone with SOCIAL_ROLE can slash coordinator reputation after an off-chain misconduct vote.
    function slashReputation(address entity, uint256 amount) external onlyRole(SOCIAL_ROLE) {
        require(registry[entity].exists, "Not registered");
        uint256 current = registry[entity].reputation;
        if (amount >= current) {
            registry[entity].reputation = 0;
        } else {
            registry[entity].reputation = current - amount;
        }
        emit ReputationSlashed(entity, registry[entity].reputation);
    }

    // Helper: set roles for external actors (admin controlled)
    function setExchange(address who) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(EXCHANGE_ROLE, who);
    }

    function setNGOVerifier(address who) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(NGO_VERIFIER, who);
    }

    // Allow the admin to top-up crisis collected amount (trustworthy process in PoC)
    function topUpCrisisCollected(uint256 crisisId, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // admin can transfer tokens to contract separately; here we just record association
        crises[crisisId].collected += amount;
    }
}
