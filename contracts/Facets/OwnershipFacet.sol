// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../LibDiamondStorage.sol";

contract OwnershipFacet {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == LibDiamondStorage.getOwner(), "OwnershipFacet: Not the owner");
        _;
    }

    function owner() external view returns (address) {
        return LibDiamondStorage.getOwner();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "OwnershipFacet: New owner is zero address");

        address previousOwner = LibDiamondStorage.getOwner();
        LibDiamondStorage.setOwner(newOwner);

        emit OwnershipTransferred(previousOwner, newOwner);
    }
}
