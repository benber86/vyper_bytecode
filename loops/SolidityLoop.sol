// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Loop {
    
    function addNumber(uint256 _number) public pure returns (uint256) {
        uint256 total = 0;
        
        for (uint256 i = 0; i < 100; i++) {
            total += _number;
        }
        
        return total;
    }
}
