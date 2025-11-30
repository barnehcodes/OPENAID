// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
 * DonationToken.sol
 * Minimal ERC20 where OpenAidCore can mint when donors deposit off-chain fiat mapping or for test PoC.
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract DonationToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // only @s with "mint role" can mint or burn

    constructor(string memory name_, string memory symbol_, address initialMinter) ERC20(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, initialMinter);
    }

    // deploys token with name and symbol
    // initialte 1st minter 
    // deployer => admin

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
    // mint sim =>POC

    function burn(address from, uint256 amount) external onlyRole(MINTER_ROLE) {
        _burn(from, amount);
    }
}
