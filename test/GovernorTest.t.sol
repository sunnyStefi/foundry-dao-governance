// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

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
    uint256 public constant ACTIVE_PROPOSAL_WAITING_TIME = 7200; // 1 day - defined in governor
    uint256 public constant FINISH_CASTING_PERIOD = 50400; // 1 week - defined in governor [cast = emettere un voto]

    address[] proposers; //if empty, anyone can propose
    address[] executors; //if empty, anyone can execute
    bytes[] calldatas;
    uint256[] values;
    address[] targets;

    function setUp() public {
        //0. setup
        governanceToken = new GovernanceToken();
        governanceToken.mint(ALICE, INITIAL_SUPPLY);
        vm.prank(ALICE);
        governanceToken.delegate(ALICE); //delegates voting power
        timelock = new Timelock(MIN_DELAY, proposers, executors, address(this)); // set admin here! otherwise the test contract cannot change roles
        governor = new GovernorController(governanceToken, timelock);

        //1. grant governer Timelock roles
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        //2. revoke admin role > we build a full decentralized dao!
        timelock.revokeRole(adminRole, address(this));

        // the DAO (governor) has a
        // TimelockController(timelockAddress) state variable
        // that controls the execution of the functions and has the ultimate say
        controlled = new Controlled(address(timelock)); // deprecated controlled.transferOwnership(address(timelock));
    }

    function test_onlyGovernanceCanUpdateControlled() public {
        vm.expectRevert();
        controlled.setValue(4);
    }

    function test_governaceCanUpdateControlled() public {
        uint256 numberToStore = 123;
        // 1. set up a proposal
        string memory description = "Store value 123";
        calldatas.push(abi.encodeWithSignature("setValue(uint256)", numberToStore));
        values.push(0);
        targets.push(address(controlled));

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // 2. state pending
        console.log("state proposal ", uint256(governor.state(proposalId)));

        // 3. update blockchain to fake time has passed -> add 1 block + time
        // warp = distorcere [the blockchain]
        // vm.warp(block.timestamp + ACTIVE_PROPOSAL_WAITING_TIME + 1); // sets block.timestamp >> useless
        vm.roll(block.number + ACTIVE_PROPOSAL_WAITING_TIME + 1); // sets block.number - min 1 block per second is needed

        // 4. state active snapshot = 7201
        console.log("state proposal ", uint256(governor.state(proposalId)));

        // 5. vote with reason
        string memory reason = "Vote reason here";
        uint8 side = 1; // Against, Favor, Abstain

        vm.prank(ALICE);
        governor.castVoteWithReason(proposalId, side, reason);

        // 6. speed up the week
        vm.roll(block.number + FINISH_CASTING_PERIOD + 1);

        //logging accounts

        // 7. Queue tx
        governor.queue(targets, values, calldatas, keccak256(abi.encodePacked(description)));

        // // TIME wait that people can go out before executing
        // vm.roll(block.number + MIN_DELAY + 1);

        // 8. Execute tx
        // governor.execute(targets, values, calldatas, keccak256(abi.encodePacked(description)));

        // 9. Check if number is set to 123
        // assertEq(controlled.getValue(), numberToStore);
    }
}
