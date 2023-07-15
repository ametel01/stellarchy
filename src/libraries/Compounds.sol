// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19.0;

import {Structs} from "./Structs.sol";

contract Compounds is Structs {
    mapping(uint256 => uint256) public steelMineLevel;

    mapping(uint256 => uint256) public quartzMineLevel;

    mapping(uint256 => uint256) public tritiumMineLevel;

    mapping(uint256 => uint256) public energyPlantLevel;

    mapping(uint256 => uint256) public dockyardLevel;

    mapping(uint256 => uint256) public labLevel;

    function _steelMineCost(uint256 currentLevel) internal pure returns (ERC20s memory) {
        ERC20s memory cost;
        cost.steel = 60 * (15 ** currentLevel) / 10 ** currentLevel;
        cost.quartz = 15 * (15 ** currentLevel) / 10 ** currentLevel;
        return cost;
    }

    function _quartzMineCost(uint256 currentLevel) internal pure returns (ERC20s memory) {
        ERC20s memory cost;
        cost.steel = 48 * (16 ** currentLevel) / 10 ** currentLevel;
        cost.quartz = 24 * (16 ** currentLevel) / 10 ** currentLevel;
        return cost;
    }

    function _tritiumMineCost(uint256 currentLevel) internal pure returns (ERC20s memory) {
        ERC20s memory cost;
        cost.steel = 225 * (15 ** currentLevel) / 10 ** currentLevel;
        cost.quartz = 75 * (15 ** currentLevel) / 10 ** currentLevel;
        return cost;
    }

    function _energyPlantCost(uint256 currentLevel) internal pure returns (ERC20s memory) {
        ERC20s memory cost;
        cost.steel = 75 * (15 ** currentLevel) / 10 ** currentLevel;
        cost.quartz = 30 * (15 ** currentLevel) / 10 ** currentLevel;
        return cost;
    }

    function _dockyardCost(uint256 currentLevel) internal pure returns (ERC20s memory) {
        ERC20s memory cost;
        cost.steel = 400 * 2 ** currentLevel;
        cost.quartz = 200 * 2 ** currentLevel;
        cost.tritium = 100 * 2 ** currentLevel;
        return cost;
    }

    function _labCost(uint256 currentLevel) internal pure returns (ERC20s memory) {
        ERC20s memory cost;
        cost.steel = 200 * 2 ** currentLevel;
        cost.quartz = 400 * 2 ** currentLevel;
        cost.tritium = 200 * 2 ** currentLevel;
        return cost;
    }

    function _steelProduction(uint256 currentLevel) internal pure returns (uint256) {
        return (30 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function _quartzProduction(uint256 currentLevel) internal pure returns (uint256) {
        return (20 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function _tritiumProduction(uint256 currentLevel) internal pure returns (uint256) {
        return (10 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function _energyPlantProduction(uint256 currentLevel) internal pure returns (uint256) {
        return (20 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function _baseMineConsumption(uint256 currentLevel) internal pure returns (uint256) {
        return (10 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function _tritiumMineConsumption(uint256 currentLevel) internal pure returns (uint256) {
        return (20 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function _productionScaler(uint256 production, uint256 available, uint256 required)
        internal
        pure
        returns (uint256)
    {
        if (available > required) {
            return production;
        } else {
            return ((available * 100 / required) * production) / 100;
        }
    }
}
