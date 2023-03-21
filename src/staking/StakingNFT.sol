// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title StakingNFT
 * @dev This contract allows users to mint ERC721 tokens as staking rewards.
 */
contract StakingNFT is ERC721 {
    uint256 totalSupply;

    /**
     * @notice Initializes the contract by setting a name and symbol for the ERC721 token.
     * @param name_ The name of the ERC721 token.
     * @param symbol_ The symbol of the ERC721 token.
     */
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /**
     * @notice Mints a new ERC721 token and assigns it to the sender as staking reward.
     */
    function mint() public {
        _mint(msg.sender, totalSupply);
        totalSupply++;
    }
}
