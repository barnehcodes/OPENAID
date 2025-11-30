// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract InKindNFT is ERC721, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _idCounter = 0;
    mapping(uint256 => string) public metadata;

    constructor(address initialMinter)
        ERC721("OpenAidInKind", "OA-NFT")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, initialMinter);
    }

    function mintTo(address to, string calldata meta)
        external
        onlyRole(MINTER_ROLE)
        returns (uint256)
    {
        _idCounter++;
        uint256 id = _idCounter;

        _safeMint(to, id);
        metadata[id] = meta;

        return id;
    }

    function burn(uint256 tokenId)
        external
        onlyRole(MINTER_ROLE)
    {
        _burn(tokenId);
    }

    // 💡 REQUIRED OVERRIDE TO FIX MULTIPLE INHERITANCE
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
