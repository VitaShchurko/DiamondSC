// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StorageFacet {
    mapping(address => uint256) private data;

    function setData(uint256 value) external {
        data[msg.sender] = value;
    }

    function getData(address user) external view returns (uint256) {
        return data[user];
    }
}
