// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IncrementMapping {
    mapping(address => uint256) public amounts;

    function increase() external {
        amounts[msg.sender] += 1;
    }
}
