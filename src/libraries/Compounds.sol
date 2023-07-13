// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./Structs.sol";

contract Compounds {
    function dockyardCost(uint256 currentLevel) public pure returns (Structs.Cost memory) {
        Structs.Cost memory cost;
        cost.steel = 400 * 2 ** currentLevel;
        cost.quartz = 200 * 2 ** currentLevel;
        cost.tritium = 100 * 2 ** currentLevel;
        return cost;
    }

    function labCost(uint256 currentLevel) public pure returns (Structs.Cost memory) {
        Structs.Cost memory cost;
        cost.steel = 200 * 2 ** currentLevel;
        cost.quartz = 400 * 2 ** currentLevel;
        cost.tritium = 200 * 2 ** currentLevel;
        return cost;
    }
}
