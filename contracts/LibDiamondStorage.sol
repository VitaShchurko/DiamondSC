// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library LibDiamondStorage {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct DiamondStorage {
        mapping(bytes4 => address) facets; // Мапінг селекторів функцій до фецетів
        address owner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function setOwner(address newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.owner = newOwner;
    }

    function getOwner() internal view returns (address) {
        DiamondStorage storage ds = diamondStorage();
        return ds.owner;
    }
}
