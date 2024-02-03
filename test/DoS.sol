// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console2} from "forge-std/Test.sol";
import {PuppyRaffle} from "../src/PuppyRaffle.sol";

contract DoS is Test {
    PuppyRaffle puppyRaffle;

    address warmUpAddress = address(1);
    address personA = address(2);
    address personB = address(3);
    address personC = address(4);

    uint256 entranceFee = 1e18;
    address feeAddress = address(99);
    uint256 duration = 1 days;

    function setUp() public {
        puppyRaffle = new PuppyRaffle(
            entranceFee,
            feeAddress,
            duration
        );
        warmUpAddress.call{value: 10 ether}("");
        personA.call{value: 10 ether}("");
        personB.call{value: 10 ether}("");
        personC.call{value: 10 ether}("");
    }

    function test_denialOfService() public {
        // We want to warm up the storage stuff
        address[] memory arr0 = new address[](1);
        arr0[0] = warmUpAddress;
        vm.prank(warmUpAddress);
        puppyRaffle.enterRaffle{value: entranceFee}(arr0);

        uint256 gasStartA = gasleft();
        address[] memory arr1 = new address[](1);
        arr1[0] = personA;
        vm.prank(personA);
        puppyRaffle.enterRaffle{value: entranceFee}(arr1);
        uint256 gasCostA = gasStartA - gasleft();

        uint256 gasStartB = gasleft();
        address[] memory arr2 = new address[](1);
        arr2[0] = personB;
        vm.prank(personB);
        puppyRaffle.enterRaffle{value: entranceFee}(arr2);
        uint256 gasCostB = gasStartB - gasleft();

        uint256 gasStartC = gasleft();
        address[] memory arr3 = new address[](1);
        arr3[0] = personC;
        vm.prank(personC);
        puppyRaffle.enterRaffle{value: entranceFee}(arr3);
        uint256 gasCostC = gasStartC - gasleft();

        console2.log("Gas cost A: %s", gasCostA);
        console2.log("Gas cost B: %s", gasCostB);
        console2.log("Gas cost C: %s", gasCostC);

        // The gas cost will just keep rising, making it harder and harder for new people to enter!

        // hvz eventually no one will be able to enter resultin in DoS
        assert(gasCostC > gasCostB);
        assert(gasCostB > gasCostA);
    }
}