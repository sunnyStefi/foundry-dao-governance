//SPDX-License-identifier:MIT

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

pragma solidity ^0.8.18;

contract Timelock is TimelockController {
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin)
        TimelockController(minDelay, proposers, executors, admin)
    {}
}
