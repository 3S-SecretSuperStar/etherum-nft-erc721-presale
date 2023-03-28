// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

/**
 * @title NFTBitmapPresale
 * @dev This contract implements an ERC721 NFT that is sold through a presale.
 * The presale is implemented using a merkle tree, with the presale whitelist stored as a BitMap.
 * The contract also implements the ERC2981 standard for royalty payments.
 */
contract NFTBitmapPresale is ERC721, IERC2981 {
    using BitMaps for BitMaps.BitMap;

    bytes32 public merkleRoot;
    uint256 public constant PRICE = 1_000 wei;
    uint256 public constant DISCOUNT_PRICE = 800 wei;
    uint256 public constant ROYALTY_BPS = 250;
    address[] public allowList;
    BitMaps.BitMap private tickets;

    /**
     * @notice initializes the BitMap with all 10 NFTs set as available.
     * @param name_ The name of the ERC721 token.
     * @param symbol_ The symbol of the ERC721 token.
     */
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        tickets._data[0] = 2 ** 10 - 1;
    }

    /**
     * @notice Sets the presale allow list and computes the Merkle root.
     * @param _allowList The list of addresses allowed to buy NFTs with presale discount.
     */
    function setPreSaleAllowList(address[] memory _allowList, bytes32 _merkleRoot) public {
        require(allowList.length == 0, "PRESALE ALREADY SET");
        allowList = _allowList;
        setMerkleRoot(_merkleRoot);
    }

    /**
     * @notice Buys a token at full price.
     * @param id The ID of the token to buy.
     */
    function buyToken(uint256 id) public payable {
        require(msg.value >= PRICE, "NOT ENOUGH VALUE TO BUY NFT");
        require(tickets.get(id), "TOKEN NOT AVAILABLE");
        _mint(msg.sender, id);
        tickets.unset(id);
    }

    /**
     * @notice Buys a token with presale discount.
     * @param merkleProof The Merkle proof to verify the buyer's eligibility for the presale discount.
     * @param id The ID of the token to buy.
     */
    function buyTokenDiscount(bytes32[] calldata merkleProof, uint256 id) public payable {
        require(verifyDiscount(merkleProof, id), "ADDRESS NOT ALLOWED TO BUY ON PRESALE");
        require(tickets.get(id), "TOKEN NOT AVAILABLE");
        require(msg.value >= DISCOUNT_PRICE, "NOT ENOUGH VALUE TO BUY NFT");
        _mint(msg.sender, id);
        tickets.unset(id);
    }

    /**
     * @notice Computes the royalty information for the token.
     * @param tokenId The ID of the token.
     * @param salePrice The sale price of the token.
     * @return receiver The address of the royalty receiver.
     * @return royaltyAmount The royalty amount in basis points.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        return (address(this), ROYALTY_BPS);
    }

    /**
     * @notice Returns true if the contract implements `IERC2981`.
     * @param interfaceId The interface identifier, as specified in ERC-165.
     * @return True if the contract implements `IERC2981`, false otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        if (interfaceId == type(IERC2981).interfaceId) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view override returns (string memory) {
        return "ipfs://QmcjkoCfLrQNdatBxnednD5zfv1UHmuhf1zTneAD6A3L3Z/";
    }
    /**
     * @notice Verifies if the caller's address with the given `merkleProof` and the id belong to the `merkleRoot`.
     * @param merkleProof The merkle proof to verify.
     * @param id Token Id corresponding to the place in the allowList array.
     * @return A boolean value representing if the discount is verified or not.
     */
    function verifyDiscount(bytes32[] calldata merkleProof, uint256 id) private view returns (bool) {
        return MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender,id)));
    }
    
    /**
     * @notice Adds Merkle root to contract.
     * @param _merkleRoot The merkle rott to add.
     */
    function setMerkleRoot(bytes32 _merkleRoot) private {
        merkleRoot = _merkleRoot;
    }
}
