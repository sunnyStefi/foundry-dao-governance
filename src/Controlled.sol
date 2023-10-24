// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Controlled is Ownable {
    uint256 private s_value;

    event Controlled_value_changed(address indexed actor);

    constructor(address owner) Ownable(owner) {
        owner = msg.sender;
    }

    /**
     * @notice Only the owner of this contract (DAO) is able to call this function
     * @dev emits msg.sender must be the DAO contract -> test it
     */
    function setValue(uint256 _value) public onlyOwner {
        s_value = _value;
        emit Controlled_value_changed(msg.sender);
    }

    function getValue() external view returns (uint256) {
        return s_value;
    }
}
