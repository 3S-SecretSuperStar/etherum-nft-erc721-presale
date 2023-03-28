pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/enumerable/PrimeNFTCounter.sol";
import "../src/enumerable/EnumerableNFT.sol";

contract EnumerableNFTTest is Test {
    EnumerableNFT nft;
    PrimeNFTCounter primeNFTCounter;
    address bob = address(1);
    address alice = address(2);

    function setUp() public {
        nft = new EnumerableNFT("EnumerableNFT", "ENFT");
        primeNFTCounter = new PrimeNFTCounter(address(nft));
        vm.startPrank(bob);
        nft.mint();
        nft.mint();
        nft.mint();
        vm.stopPrank();
    }

    /// @notice Test that prime count for bob equals 2 after 3 initial mints due to id 2 and 3
    function testPrimeCount() public {
        assertEq(primeNFTCounter.getPrimeCount(bob), 2);
    }

    /// @notice Test that prime count for alice equals 1 after 3 mints due to id 5
    function testPrimeCountAfterMultipleMints() public {
        vm.startPrank(alice);
        nft.mint();
        nft.mint();
        nft.mint();
        assertEq(primeNFTCounter.getPrimeCount(bob), 2);
        assertEq(primeNFTCounter.getPrimeCount(alice), 1);
    }
}
