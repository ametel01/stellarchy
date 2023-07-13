// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./Structs.sol";

contract Mines {
    function steelMineCost(uint256 currentLevel) public pure returns (Structs.Cost memory) {
        Structs.Cost memory cost;
        cost.steel = 60 * (15 ** currentLevel) / 10 ** currentLevel;
        cost.quartz = 15 * (15 ** currentLevel) / 10 ** currentLevel;
        return cost;
    }

    function quartzMineCost(uint256 currentLevel) public pure returns (Structs.Cost memory) {
        Structs.Cost memory cost;
        cost.steel = 48 * (16 ** currentLevel) / 10 ** currentLevel;
        cost.quartz = 24 * (16 ** currentLevel) / 10 ** currentLevel;
        return cost;
    }

    function tritiumMineCost(uint256 currentLevel) public pure returns (Structs.Cost memory) {
        Structs.Cost memory cost;
        cost.steel = 225 * (15 ** currentLevel) / 10 ** currentLevel;
        cost.quartz = 30 * (15 ** currentLevel) / 10 ** currentLevel;
        return cost;
    }

    function energyPlantCost(uint256 currentLevel) public pure returns (Structs.Cost memory) {
        Structs.Cost memory cost;
        cost.steel = 75 * (15 ** currentLevel) / 10 ** currentLevel;
        cost.quartz = 30 * (15 ** currentLevel) / 10 ** currentLevel;
        return cost;
    }

    function steelProduction(uint256 currentLevel) public pure returns (uint256) {
        return (30 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function quartzProduction(uint256 currentLevel) public pure returns (uint256) {
        return (20 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function tritiumProduction(uint256 currentLevel) public pure returns (uint256) {
        return (10 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function energyPlantProduction(uint256 currentLevel) public pure returns (uint256) {
        return (20 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function baseMineConsumption(uint256 currentLevel) public pure returns (uint256) {
        return (10 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function tritiumMineConsumption(uint256 currentLevel) public pure returns (uint256) {
        return (20 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    function productionScaler(uint256 production, uint256 available, uint256 required) public pure returns (uint256) {
        if (available > required) {
            return production;
        } else {
            return ((available * 100 / required) * production) / 100;
        }
    }
}
