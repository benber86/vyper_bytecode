// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract YourContract {
    struct SolidityStruct {
        uint256 foo;
        bool bar;
        uint256 baz;
    }

    mapping(address => SolidityStruct) public userStructs;

    function a(uint256 b) external pure returns (SolidityStruct memory) {
        SolidityStruct memory c = SolidityStruct(b, b & 1 == 0, b**2);
        return c;
    }

    function k(uint256 b) external {
        if (userStructs[msg.sender].foo == 0) {
            userStructs[msg.sender] = SolidityStruct(b, b & 1 == 0, b**2);
        }
    }
}
