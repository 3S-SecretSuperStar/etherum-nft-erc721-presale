// SPDX-License-Identifier: MIT
pragma solidity >=0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title StakingToken
 * @dev A simple ERC20 token that can be used for staking and unstaking.
 */
contract StakingToken is ERC20 {
    address owner;

    /**
     * @notice Modifier that only allows the owner of the contract to call a function.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /**
     * @notice Initializes the name and symbol of the token and sets the owner.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        owner = msg.sender;
    }

    /**
     * @notice Mints new tokens and assigns them to the specified receiver.
     * @param receiver The address that will receive the newly minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address receiver, uint256 amount) public onlyOwner {
        _mint(receiver, amount);
    }
}
