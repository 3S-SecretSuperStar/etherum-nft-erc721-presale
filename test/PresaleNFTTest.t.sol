pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/presale/NFTBitmapPresale.sol";
import "../src/presale/NFTMappingPresale.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

contract PresaleNFTTest is Test {
    using BitMaps for BitMaps.BitMap;

    NFTBitmapPresale bitMapNFT;
    NFTMappingPresale mappingNFT;
    address bob = address(1);
    address alice = address(2);

    function setUp() public {
        bitMapNFT = new NFTBitmapPresale("BitMapNFT", "BMNFT");
        mappingNFT = new NFTMappingPresale("MappingNFT", "MNFT");
        address[] memory allowList = new address[](2);
        allowList[0] = bob;
        allowList[1] = alice;
        bitMapNFT.setPreSaleAllowList(allowList);
        mappingNFT.setPreSaleAllowList(allowList);
    }

    /// @notice Test the correct nft balance after the discounted purchase under the BitMap presale.
    function testBitmapPresale() public {
        vm.deal(alice, 10 ether);
        vm.startPrank(alice);
        bytes32[] memory merkleProof = new bytes32[](1);
        merkleProof[0] = keccak256(abi.encodePacked(bitMapNFT.allowList(0)));
        bitMapNFT.buyTokenDiscount{value: 8 ether}(merkleProof, 1);
        assertEq(bitMapNFT.balanceOf(alice), 1);
    }

    /// @notice Test the correct nft balance after the discounted purchase under the Mapping presale.
    function testMappingPresale() public {
        vm.deal(alice, 10 ether);
        vm.startPrank(alice);
        bytes32[] memory merkleProof = new bytes32[](1);
        merkleProof[0] = keccak256(abi.encodePacked(mappingNFT.allowList(0)));
        mappingNFT.buyTokenDiscount{value: 8 ether}(merkleProof, 1);
        assertEq(mappingNFT.balanceOf(alice), 1);
    }
}
