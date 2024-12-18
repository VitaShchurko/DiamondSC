// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LibDiamondStorage.sol";

contract Diamond {
    struct FacetCut {
        address facetAddress;
        uint8 action; // 0 = Add, 1 = Replace, 2 = Remove
        bytes4[] functionSelectors;
    }

    event DiamondCut(FacetCut[] diamondCut, address init, bytes _calldata);

    constructor(address owner) {
        LibDiamondStorage.setOwner(owner);
    }

    fallback() external payable {
        address facet = LibDiamondStorage.diamondStorage().facets[msg.sig];
        require(facet != address(0), "Diamond: Function does not exist");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external {
        require(msg.sender == LibDiamondStorage.getOwner(), "Diamond: Not authorized");

        for (uint256 i = 0; i < _diamondCut.length; i++) {
            FacetCut memory cut = _diamondCut[i];

            if (cut.action == 0) {
                for (uint256 j = 0; j < cut.functionSelectors.length; j++) {
                    require(
                        LibDiamondStorage.diamondStorage().facets[cut.functionSelectors[j]] == address(0),
                        "Diamond: Function already exists"
                    );
                    LibDiamondStorage.diamondStorage().facets[cut.functionSelectors[j]] = cut.facetAddress;
                }
            } else if (cut.action == 1) {
                for (uint256 j = 0; j < cut.functionSelectors.length; j++) {
                    require(
                        LibDiamondStorage.diamondStorage().facets[cut.functionSelectors[j]] != address(0),
                        "Diamond: Function does not exist"
                    );
                    LibDiamondStorage.diamondStorage().facets[cut.functionSelectors[j]] = cut.facetAddress;
                }
            } else if (cut.action == 2) {
                for (uint256 j = 0; j < cut.functionSelectors.length; j++) {
                    require(
                        LibDiamondStorage.diamondStorage().facets[cut.functionSelectors[j]] != address(0),
                        "Diamond: Function does not exist"
                    );
                    LibDiamondStorage.diamondStorage().facets[cut.functionSelectors[j]] = address(0);
                }
            } else {
                revert("Diamond: Invalid action");
            }
        }

        emit DiamondCut(_diamondCut, _init, _calldata);

        if (_init != address(0)) {
            require(_calldata.length > 0, "Diamond: _calldata is empty");
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            require(success, string(error));
        }
    }
}
