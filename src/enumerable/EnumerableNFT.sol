// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title EnumerableNFT
 * @dev This contract allows users to mint non-fungible tokens (NFTs) in a sequential and enumerable manner.
 */
contract EnumerableNFT is ERC721Enumerable {
    uint256 public constant MAX_SUPPLY = 20;

    /**
     * @notice Initialize the ERC721Enumerable contract.
     * @param name_ The name of the NFT token.
     * @param symbol_ The symbol of the NFT token.
     */
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /**
     * @notice Mint a new NFT to the caller with 1 as the starting id.
     */
    function mint() public {
        uint id = totalSupply() + 1;
        require(id <= MAX_SUPPLY, "MAXED AMOUNT REACHED");
        _safeMint(msg.sender, id);
    }
}
