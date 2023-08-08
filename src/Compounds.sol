// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs} from "./libraries/Structs.sol";

/**
 * @title Compounds
 * @dev This contract manages game infrastructures and their cost in the game.
 * The infrastructures include: steel mine, quartz mine, tritium mine, energy plant, laboratory and dockyard.
 *
 * Note: All functions are internal or internal pure, meaning they can only be called from this contract or contracts that inherit from it.
 */
contract Compounds {
    /// @notice A mapping of planet identifiers to their steel mine levels.
    /// @dev Key is a unique planet identifier, value is the level of the steel mine on that planet.
    mapping(uint256 => uint256) public steelMineLevel;

    /// @notice A mapping of planet identifiers to their quartz mine levels.
    /// @dev Key is a unique planet identifier, value is the level of the quartz mine on that planet.
    mapping(uint256 => uint256) public quartzMineLevel;

    /// @notice A mapping of planet identifiers to their tritium mine levels.
    /// @dev Key is a unique planet identifier, value is the level of the tritium mine on that planet.
    mapping(uint256 => uint256) public tritiumMineLevel;

    /// @notice A mapping of planet identifiers to their energy plant levels.
    /// @dev Key is a unique planet identifier, value is the level of the energy plant on that planet.
    mapping(uint256 => uint256) public energyPlantLevel;

    /// @notice A mapping of planet identifiers to their dockyard levels.
    /// @dev Key is a unique planet identifier, value is the level of the dockyard on that planet.
    mapping(uint256 => uint256) public dockyardLevel;

    /// @notice A mapping of planet identifiers to their laboratory levels.
    /// @dev Key is a unique planet identifier, value is the level of the laboratory on that planet.
    mapping(uint256 => uint256) public labLevel;

    /**
     * @dev Calculates the cost of upgrading the steel mine to the next level.
     *
     * @param currentLevel The current level of the steel mine.
     *
     * @return cost An instance of the Structs.ERC20s struct representing the cost of the upgrade.
     */
    function _steelMineCost(uint256 currentLevel) internal pure returns (Structs.ERC20s memory) {
        Structs.ERC20s memory cost;
        cost.steel = (60 * (15 ** currentLevel)) / 10 ** currentLevel;
        cost.quartz = (15 * (15 ** currentLevel)) / 10 ** currentLevel;
        return cost;
    }

    /**
     * @dev Calculates the cost of upgrading the quartz mine to the next level.
     *
     * @param currentLevel The current level of the quartz mine.
     *
     * @return cost An instance of the Structs.ERC20s struct representing the cost of the upgrade.
     */
    function _quartzMineCost(uint256 currentLevel) internal pure returns (Structs.ERC20s memory) {
        Structs.ERC20s memory cost;
        cost.steel = (48 * (16 ** currentLevel)) / 10 ** currentLevel;
        cost.quartz = (24 * (16 ** currentLevel)) / 10 ** currentLevel;
        return cost;
    }

    /**
     * @dev Calculates the cost of upgrading the tritium mine to the next level.
     *
     * @param currentLevel The current level of the tritium mine.
     *
     * @return cost An instance of the Structs.ERC20s struct representing the cost of the upgrade.
     */
    function _tritiumMineCost(uint256 currentLevel) internal pure returns (Structs.ERC20s memory) {
        Structs.ERC20s memory cost;
        cost.steel = (225 * (15 ** currentLevel)) / 10 ** currentLevel;
        cost.quartz = (75 * (15 ** currentLevel)) / 10 ** currentLevel;
        return cost;
    }

    /**
     * @dev Calculates the cost of upgrading the energy plant to the next level.
     *
     * @param currentLevel The current level of the energy plant.
     *
     * @return cost An instance of the Structs.ERC20s struct representing the cost of the upgrade.
     */
    function _energyPlantCost(uint256 currentLevel) internal pure returns (Structs.ERC20s memory) {
        Structs.ERC20s memory cost;
        cost.steel = (75 * (15 ** currentLevel)) / 10 ** currentLevel;
        cost.quartz = (30 * (15 ** currentLevel)) / 10 ** currentLevel;
        return cost;
    }

    /**
     * @dev Calculates the cost of upgrading the dockyard to the next level.
     *
     * @param currentLevel The current level of the dockyard.
     *
     * @return cost An instance of the Structs.ERC20s struct representing the cost of the upgrade.
     */
    function _dockyardCost(uint256 currentLevel) internal pure returns (Structs.ERC20s memory) {
        Structs.ERC20s memory cost;
        cost.steel = 400 * 2 ** currentLevel;
        cost.quartz = 200 * 2 ** currentLevel;
        cost.tritium = 100 * 2 ** currentLevel;
        return cost;
    }

    /**
     * @dev Calculates the cost of upgrading the laboratory to the next level.
     *
     * @param currentLevel The current level of the laboratory.
     *
     * @return cost An instance of the Structs.ERC20s struct representing the cost of the upgrade.
     */
    function _labCost(uint256 currentLevel) internal pure returns (Structs.ERC20s memory) {
        Structs.ERC20s memory cost;
        cost.steel = 200 * 2 ** currentLevel;
        cost.quartz = 400 * 2 ** currentLevel;
        cost.tritium = 200 * 2 ** currentLevel;
        return cost;
    }

    /**
     * @notice Calculates the steel production for a given level.
     * @param currentLevel The current level of the steel production.
     * @return The calculated steel production value.
     * @dev If the current level is 0, it returns a base production of 10.
     * Otherwise, it calculates the production using the formula (30 * currentLevel * 11 ^ currentLevel) / 10 ^ currentLevel.
     */
    function _steelProduction(uint256 currentLevel) internal pure returns (uint256) {
        if (currentLevel == 0) {
            return 10;
        }
        return (30 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    /**
     * @notice Calculates the quartz production for a given level.
     * @param currentLevel The current level of the quartz production.
     * @return The calculated quartz production value.
     * @dev If the current level is 0, it returns a base production of 10.
     * Otherwise, it calculates the production using the formula (20 * currentLevel * 11 ^ currentLevel) / 10 ^ currentLevel.
     */
    function _quartzProduction(uint256 currentLevel) internal pure returns (uint256) {
        if (currentLevel == 0) {
            return 10;
        }
        return (20 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    /**
     * @notice Calculates the tritium production for a given level.
     * @param currentLevel The current level of the tritium production.
     * @return The calculated tritium production value.
     * @dev It calculates the production using the formula (10 * currentLevel * 11 ^ currentLevel) / 10 ^ currentLevel.
     * Notice there is no base production when level is 0.
     */
    function _tritiumProduction(uint256 currentLevel) internal pure returns (uint256) {
        return (10 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    /**
     * @notice Calculates the energy plant production for a given level.
     * @param currentLevel The current level of the energy plant.
     * @return The calculated energy plant production value.
     * @dev It calculates the production using the formula (20 * currentLevel * 11 ^ currentLevel) / 10 ^ currentLevel.
     * Notice there is no base production when level is 0.
     */
    function _energyPlantProduction(uint256 currentLevel) internal pure returns (uint256) {
        return (20 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    /**
     * @notice Calculate base mine consumption based on the current level.
     * @dev This function uses a mathematical formula to simulate mine consumption increase per level.
     *
     * @param currentLevel The current level of the base mine.
     *
     * @return uint256 The calculated mine consumption for the given level.
     */
    function _baseMineConsumption(uint256 currentLevel) internal pure returns (uint256) {
        return (10 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    /**
     * @notice Calculate tritium mine consumption based on the current level.
     * @dev This function uses a mathematical formula to simulate mine consumption increase per level.
     * It is similar to _baseMineConsumption, but with different coefficients.
     *
     * @param currentLevel The current level of the tritium mine.
     *
     * @return uint256 The calculated mine consumption for the given level.
     */
    function _tritiumMineConsumption(uint256 currentLevel) internal pure returns (uint256) {
        return (20 * currentLevel * 11 ** currentLevel) / 10 ** currentLevel;
    }

    /**
     * @notice Calculates the scaled production value based on the available and required resources.
     *
     * @dev If the available resources are more than the required ones, it returns the initial production value.
     * Otherwise, it scales the production proportionally to the available/required resources ratio.
     *
     * @param production The initial production value.
     * @param available The amount of available resources.
     * @param required The amount of required resources.
     *
     * @return uint256 The scaled production value.
     */
    function _productionScaler(uint256 production, uint256 available, uint256 required)
        internal
        pure
        returns (uint256)
    {
        if (available > required) {
            return production;
        } else {
            return (((available * 100) / required) * production) / 100;
        }
    }
}
