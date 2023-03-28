// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title PrimeNFTCounter
 * @dev A contract for counting the number of prime numbered ERC721 tokens owned by a particular address.
 */
contract PrimeNFTCounter {
    ERC721Enumerable private nft;
    uint256[] private specialIds = [2, 3, 5, 7, 11, 13, 17, 19];

    /**
     * @dev Initializes the contract instance with the address of an existing ERC721Enumerable contract.
     * @param _nft The address of the ERC721Enumerable contract.
     */
    constructor(address _nft) {
        nft = ERC721Enumerable(_nft);
    }

    /**
     * @notice the number of prime numbered tokens owned by a particular address.
     * @param user The address of the user for whom the count of prime numbered tokens is to be returned.
     * @return primeCount The number of prime numbered tokens owned by the specified address.
     */
    function getPrimeCount(address user) public view returns (uint256) {
        uint userAmount = nft.balanceOf(user);
        uint256 primeCount;
        for (uint256 i = 0; i < userAmount; i++) {
            uint userId = nft.tokenOfOwnerByIndex(user, i);
            for (uint256 j = 0; j < specialIds.length; j++) {
                if (specialIds[j] == userId) {
                    primeCount++;
                }
            }
        }
        return primeCount;
    }
}
