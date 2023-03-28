// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/staking/Staking.sol";
import "../src/staking/StakingNFT.sol";
import "../src/staking/StakingToken.sol";

contract StackingNFTTest is Test {
    StakingNFT nft;
    StakingToken stakingToken;
    Staking staking;
    address bob = address(1);
    address alice = address(2);

    function setUp() public {
        nft = new StakingNFT("StackingNFT", "SNFT");
        staking = new Staking(address(nft));
        vm.prank(bob);
        nft.mint();
    }

    function testNonTokenMinter() public {
        vm.startPrank(bob);
        stakingToken = StakingToken(staking.getTokenAddress());
        vm.expectRevert("NOT OWNER");
        stakingToken.mint(bob, 10);
    }

    function testFakeNFTStake() public {
        StakingNFT nftFake = new StakingNFT("FakeStackingNFT", "FSNFT");
        vm.startPrank(bob);
        nftFake.mint();
        vm.expectRevert("NOT NFT CONTRACT");
        nftFake.safeTransferFrom(bob, address(staking), 0);
    }

    /// @notice Test bob correctly collects 10 tokens after depositing his NFT.
    function testStakeCollect() public {
        vm.prank(bob);
        nft.safeTransferFrom(bob, address(staking), 0);
        vm.warp(block.timestamp + 1 days);
        vm.prank(bob);
        staking.collectTokens(0);
        stakingToken = StakingToken(staking.getTokenAddress());
        assertEq(stakingToken.balanceOf(bob), 10);
    }
    

    /// @notice Test bob correctly collects 20 tokens after depositing his NFT and collecting two times the rewards.
    function testStakeCollect2Days() public {
        vm.prank(bob);
        nft.safeTransferFrom(bob, address(staking), 0);
        vm.warp(block.timestamp + 1 days);
        vm.startPrank(bob);
        staking.collectTokens(0);
        vm.warp(block.timestamp + 1 days);
        staking.collectTokens(0);
        stakingToken = StakingToken(staking.getTokenAddress());
        assertEq(stakingToken.balanceOf(bob), 20);
    }

    /// @notice Test bob is not able to collect 20 tokens if the require time interval has not been met.
    function testStakeCollectTimeInterval() public {
        vm.prank(bob);
        nft.safeTransferFrom(bob, address(staking), 0);
        vm.warp(block.timestamp + 1 days);
        vm.startPrank(bob);
        staking.collectTokens(0);
        vm.expectRevert("TIME INTERVAL HAS NOT BEEN REACHED");
        staking.collectTokens(0);
    }

    function testNotOwnerCollectT() public {
        vm.prank(bob);
        nft.safeTransferFrom(bob, address(staking), 0);
        vm.warp(block.timestamp + 1 days);
        vm.startPrank(alice);
        vm.expectRevert("NOT OWNER");
        staking.collectTokens(0);
    }

    /// @notice Test that bob is able to withdraw succesfully his nft.
    function testWithdraw() public {
        vm.prank(bob);
        nft.safeTransferFrom(bob, address(staking), 0);
        vm.warp(block.timestamp + 1 days);
        vm.startPrank(bob);
        staking.collectTokens(0);
        staking.withDrawNft(0);
        stakingToken = StakingToken(staking.getTokenAddress());
        assertEq(stakingToken.balanceOf(bob), 10);
        assertEq(nft.ownerOf(0), bob);
    }

    function testStakeAlreadyWithdrawn() public {
        vm.prank(bob);
        nft.safeTransferFrom(bob, address(staking), 0);
        vm.warp(block.timestamp + 1 days);
        vm.startPrank(bob);
        staking.withDrawNft(0);
        vm.expectRevert("NO INFORMATION AVAILABLE");
        staking.collectTokens(0);
    }

    function testNotOwnerWithdraw() public {
        vm.prank(bob);
        nft.safeTransferFrom(bob, address(staking), 0);
        vm.warp(block.timestamp + 1 days);
        vm.startPrank(alice);
        vm.expectRevert("NOT OWNER");
        staking.withDrawNft(0);
    }

}
