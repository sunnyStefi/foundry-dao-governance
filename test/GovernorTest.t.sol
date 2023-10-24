// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";

import {GovernanceToken} from "../src/GovernanceToken.sol";
import {GovernorController} from "../src/GovernorController.sol";
import {Controlled} from "../src/Controlled.sol";
import {Timelock} from "../src/Timelock.sol";

contract GovernorTest is Test {
    GovernanceToken governanceToken;
    Timelock timelock;
    GovernorController governor;
    Controlled controlled;

    address public ALICE = makeAddr("alice");
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 3600; //1 hour - delay after the vote passes: no one can execute a proposal until this time has passed

    address[] proposers; //if empty, anyone can propose
    address[] executors; //if empty, anyone can execute

    function setUp() public {
        //0. setup
        governanceToken = new GovernanceToken();
        governanceToken.mint(ALICE, INITIAL_SUPPLY);
        vm.startPrank(ALICE);
        governanceToken.delegate(ALICE); //delegates voting power
        timelock = new Timelock(MIN_DELAY, proposers, executors);
        governor = new GovernorController(governanceToken, timelock);

        //1. grant governer Timelock roles
        //2. remove timelock as admin
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 cancellerRole = timelock.CANCELLER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(cancellerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        vm.stopPrank();

        controlled = new Controlled(address(timelock));
        // controlled.transferOwnership(address(timelock));//not needed: the last say is 
    }

    function test_() public {}
}
