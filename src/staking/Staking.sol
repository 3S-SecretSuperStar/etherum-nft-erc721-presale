// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./StakingToken.sol";

/**
 * @title Staking Contract
 * @dev This contract allows users to stake ERC721 tokens and receive rewards in the form of a custom ERC20 token.
 */
contract Staking {
    uint256 constant REWARD = 10;
    struct OwnerInfo {
        uint256 depositTime;
        address owner;
        bool empty;
    }
    mapping(uint256 => OwnerInfo) public originalOwner;
    StakingToken stakingToken;
    ERC721 nft;

    /**
     * @notice Initialize and set the NFT being staked and deploys the custom ERC20 token.
     * @param _nft Address of the ERC721 token being staked
     */
    constructor(address _nft) {
        nft = ERC721(_nft);
        stakingToken = new StakingToken("StakingToken", "STNFT");
    }

    /**
     * @notice Returns the address of the custom ERC20 token used for rewards.
     * @return The address of the custom ERC20 token.
     */
    function getTokenAddress() public view returns (address) {
        return address(stakingToken);
    }

    /**
     * @notice Withdraws the staked NFT from the contract and sends it to the owner.
     * @param tokenId The ID of the NFT being withdrawn.
     */
    function withDrawNft(uint256 tokenId) public {
        require(originalOwner[tokenId].owner == msg.sender, "NOT OWNER");
        originalOwner[tokenId].empty = true;
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /**
     * @notice Collects the reward tokens for a staked NFT if the time interval requirement has been met.
     * @param tokenId The ID of the NFT being collected.
     */
    function collectTokens(uint256 tokenId) public {
        require(originalOwner[tokenId].owner == msg.sender, "NOT OWNER");
        require(!originalOwner[tokenId].empty, "NO INFORMATION AVAILABLE");
        require((block.timestamp - originalOwner[tokenId].depositTime) >= 1 days, "TIME INTERVAL HAS NOT BEEN REACHED");
        stakingToken.mint(msg.sender, REWARD);
        originalOwner[tokenId].depositTime = block.timestamp;
    }

    /**
     * @dev Receives the staked NFT and sets the initial staking information.
     * @param operator Address of the operator that initiated the transfer.
     * @param from Address of the NFT owner that initiated the transfer.
     * @param tokenId The ID of the NFT being staked.
     * @param data Additional data that was sent with the transfer.
     * @return The selector of the onERC721Received function.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        require(address(nft) == msg.sender, "NOT NFT CONTRACT");
        originalOwner[tokenId].depositTime = block.timestamp;
        originalOwner[tokenId].owner = from;
        originalOwner[tokenId].empty = false;
        return IERC721Receiver.onERC721Received.selector;
    }
}
