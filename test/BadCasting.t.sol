// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {PuppyRaffle} from "../src/PuppyRaffle.sol";

contract BadCasting is Test {

    PuppyRaffle puppyRaffle;
    uint256 entranceFee = 1e20;
    address playerOne = address(1);
    address playerTwo = address(2);
    address playerThree = address(3);
    address playerFour = address(4);
    address feeAddress = address(99);
    uint256 duration = 1 days;

    function setUp() public {
        puppyRaffle = new PuppyRaffle(
            entranceFee,
            feeAddress,
            duration
        );
    }

    //////////////////////
    /// EnterRaffle    ///
    /////////////////////

    // If the fee is greater than 2^64-1 the feeAddress will not receive
    // the full amount due to a bad downcasting
    // It won't allow to tranfer the right amount because it thinks that 
    // the raffle is not over yet 
    // the raffle is over when totalFees == balance of the Puppy Raffle contract
    function testOwnerGetsLessFees() public {
        address[] memory players = new address[](4);
        players[0] = playerOne;
        players[1] = playerTwo;
        players[2] = playerThree;
        players[3] = playerFour;
        
        puppyRaffle.enterRaffle{value: entranceFee * 4}(players);
        console.log("Players 1, 2, 3 & 4 have entered the raffle");
        
        // The fee address should recive 20% of the total entrance fees
        uint256 correctFee = ((entranceFee * 4) * 20) / 100;

        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number + 1);

        puppyRaffle.selectWinner();

        uint64 incorrectFee = uint64(correctFee);
        console.log("Should have received: ", correctFee );
        console.log("    Instead received: ", incorrectFee);

        vm.expectRevert("PuppyRaffle: There are currently players active!");
        puppyRaffle.withdrawFees();     
    } 
}
