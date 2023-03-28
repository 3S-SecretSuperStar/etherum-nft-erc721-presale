// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

/**
 * @title NFTMappingPresale
 * @dev This contract implements an ERC721 NFT that is sold through a presale.
 * The presale is implemented using a merkle tree, with the presale whitelist stored as a mapping.
 * The contract also implements the ERC2981 standard for royalty payments.
 */
contract NFTMappingPresale is ERC721, IERC2981 {
    bytes32 public merkleRoot;
    uint256 public constant PRICE = 10 ether;
    uint256 public constant DISCOUNT_PRICE = 8 ether;
    uint256 public constant ROYALTY_BPS = 250;
    address[] public allowList;
    mapping(uint256 => uint256) private tickets;

    /**
     * @notice initializes the NFT.
     * @param name_ The name of the ERC721 token.
     * @param symbol_ The symbol of the ERC721 token.
     */
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /**
     * @notice Sets the presale allow list and computes the Merkle root.
     * @param _allowList The list of addresses allowed to buy NFTs with presale discount.
     */
    function setPreSaleAllowList(address[] memory _allowList) public {
        require(allowList.length == 0, "PRESALE ALREADY SET");
        allowList = _allowList;
        merkleRoot = setMerkleRoot(_allowList);
    }

    /**
     * @dev Buys a token at full price.
     * @param id The ID of the token to buy.
     */
    function buyToken(uint256 id) public payable {
        require(msg.value >= PRICE, "NOT ENOUGH VALUE TO BUY NFT");
        require(tickets[id] != 1, "TOKEN NOT AVAILABLE");
        _mint(msg.sender, id);
        tickets[id] = 1;
    }

    /**
     * @notice Buys a token with presale discount.
     * @param merkleProof The Merkle proof to verify the buyer's eligibility for the presale discount.
     * @param id The ID of the token to buy.
     */
    function buyTokenDiscount(bytes32[] calldata merkleProof, uint256 id) public payable {
        require(verifyDiscount(merkleProof), "ADDRESS NOT ALLOWED TO BUY ON PRESALE");
        require(allowList[id] == msg.sender, "ID NOT ASSIGNED IN ALLOWLIST");
        require(tickets[id] != 1, "TOKEN NOT AVAILABLE");
        require(msg.value >= DISCOUNT_PRICE, "NOT ENOUGH VALUE TO BUY NFT");
        _mint(msg.sender, id);
        tickets[id] = 1;
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
     * @dev Returns true if the contract implements `IERC2981`.
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
     * @notice Verifies if the caller's address with the given `merkleProof` are valid given the `merkleRoot`.
     * @param merkleProof The merkle proof to verify.
     * @return A boolean value representing if the discount is verified or not.
     */
    function verifyDiscount(bytes32[] calldata merkleProof) private view returns (bool) {
        return MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender)));
    }

    /**
     * @dev Computes the merkle root from the given `_allowList`.
     * @param _allowList The array of allowed addresses to compute the merkle root from.
     * @return The computed merkle root.
     */
    function setMerkleRoot(address[] memory _allowList) private pure returns (bytes32) {
        bytes32 computedHash;
        for (uint256 i = 0; i < _allowList.length; i++) {
            if (computedHash == bytes32(0)) {
                computedHash = keccak256(abi.encodePacked(_allowList[i]));
                i++;
            }

            computedHash = hashPair(computedHash, keccak256(abi.encodePacked(_allowList[i])));
        }
        return computedHash;
    }

    /**
     * @notice Computes the hash of a pair of bytes32 values.
     * @param a The first bytes32 value.
     * @param b The second bytes32 value.
     * @return hash The hash of the pair of bytes32 values.
     */
    function hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? efficientHash(a, b) : efficientHash(b, a);
    }
    
    /**
     * @notice Computes the keccak256 hash of two bytes32 values using memory-safe assembly.
     * @param a The first bytes32 value.
     * @param b The second bytes32 value.
     * @return value The keccak256 hash of the two bytes32 values.
     */
    function efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
