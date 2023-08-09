// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs as S} from "./libraries/Structs.sol";

/**
 * @title Defences Contract
 * @dev This contract manages defence technologies and their cost and level requirements in the game.
 * The defence technologies include: blaster, beam, astral launcher, and plasma projector.
 *
 * Note: All functions are internal or internal pure, meaning they can only be called from this contract or contracts that inherit from it.
 */
contract Defences {
    mapping(uint256 => uint32) internal blasterAvailable;

    mapping(uint256 => uint32) internal beamAvailable;

    mapping(uint256 => uint32) internal astralLauncherAvailable;

    mapping(uint256 => uint32) internal plasmaAvailable;

    /**
     * @dev Calculates the cost of defense in terms of various resources based on the quantity.
     * @param quantity The number of defenses to be produced.
     * @param _cost The cost of a single defense unit.
     * @return cost The total cost of the desired quantity of defenses.
     */
    function defencesCost(uint256 quantity, S.ERC20s memory _cost) internal pure returns (S.ERC20s memory) {
        return S.ERC20s({
            steel: _cost.steel * quantity,
            quartz: _cost.quartz * quantity,
            tritium: _cost.tritium * quantity
        });
    }

    /**
     * @dev Checks if the dockyard level meets the requirement to unlock the blaster defense.
     * @param dockyardLevel The current level of the dockyard.
     */
    function blasterRequirements(uint256 dockyardLevel) internal pure {
        require(dockyardLevel >= 1, "Level 1 Dockyard is required");
    }

    /**
     * @dev Checks if the dockyard level and tech levels meet the requirement to unlock the beam defense.
     * @param dockyardLevel The current level of the dockyard.
     * @param techs The current tech levels.
     */
    function beamRequirements(uint256 dockyardLevel, S.Techs memory techs) internal pure {
        require(
            dockyardLevel >= 2 && techs.energyInnovation >= 2 && techs.beamTechnology >= 3,
            "Requirements not met: Level 2 Dockyard, Level 2 Energy tech, Level 3 Beam Tech required"
        );
    }

    /**
     * @dev Checks if the dockyard level and tech levels meet the requirement to unlock the astral launcher defense.
     * @param dockyardLevel The current level of the dockyard.
     * @param techs The current tech levels.
     */
    function astralLauncherRequirements(uint256 dockyardLevel, S.Techs memory techs) internal pure {
        require(dockyardLevel >= 6, "Level 6 Dockyard is required");
        require(techs.energyInnovation >= 6, "Level 6 Energy tech required");
        require(techs.armsDevelopment >= 3, "Level 3 Arms Development required");
        require(techs.shieldTech >= 1, "Level 1 Shield Tech required");
    }

    /**
     * @dev Checks if the dockyard level and tech levels meet the requirement to unlock the plasma projector defense.
     * @param dockyardLevel The current level of the dockyard.
     * @param techs The current tech levels.
     */
    function plasmaProjectorRequirements(uint256 dockyardLevel, S.Techs memory techs) internal pure {
        require(dockyardLevel >= 8, "Level 8 Dockyard is required");
        require(techs.plasmaEngineering >= 7, "Level 7 Plasma tech required");
    }

    /**
     * @dev Returns the unit costs for each defense technology.
     * @return costs The unit costs of the defense technologies.
     */
    function _defencesUnitCost() internal pure returns (S.DefencesCost memory) {
        S.DefencesCost memory costs;
        costs.blaster.steel = 2000;

        costs.beam.steel = 6000;
        costs.beam.quartz = 2000;

        costs.astralLauncher.steel = 20000;
        costs.astralLauncher.quartz = 15000;
        costs.astralLauncher.steel = 2000;

        costs.plasmaProjector.steel = 50000;
        costs.plasmaProjector.quartz = 50000;
        costs.plasmaProjector.tritium = 3000;

        return costs;
    }
}
