// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Treasury} from "../src/core/Treasury.sol";

contract TreasuryTest is Test {
    Treasury public treasury;

    address user1 = address(1);
    address user2 = address(2);
    address unauthorized = address(3);
    address tokenAddress;

    function setUp() public {
        tokenAddress = address(7);
        treasury = new Treasury(tokenAddress);
    }
}
