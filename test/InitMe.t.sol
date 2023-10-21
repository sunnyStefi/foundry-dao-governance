// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {InitMe} from "../src/InitMe.sol";

contract InitMeTest is Test {
    InitMe public counter;

    function setUp() public {
        counter = new InitMe();
    }

    function test_() public {}
}
