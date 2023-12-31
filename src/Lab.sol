// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs as S} from "./libraries/Structs.sol";
import {ID} from "./libraries/ID.sol";

contract Lab {
    mapping(uint256 => uint256) internal energyInnovationLevel;

    mapping(uint256 => uint256) internal digitalSystemsLevel;

    mapping(uint256 => uint256) internal beamTechnologyLevel;

    mapping(uint256 => uint256) internal armourInnovationLevel;

    mapping(uint256 => uint256) internal ionSystemsLevel;

    mapping(uint256 => uint256) internal plasmaEngineeringLevel;

    mapping(uint256 => uint256) internal stellarPhysicsLevel;

    mapping(uint256 => uint256) internal armsDevelopmentLevel;

    mapping(uint256 => uint256) internal shieldTechLevel;

    mapping(uint256 => uint256) internal spacetimeWarpLevel;

    mapping(uint256 => uint256) internal combustiveDriveLevel;

    mapping(uint256 => uint256) internal thrustPropulsionLevel;

    mapping(uint256 => uint256) internal warpDriveLevel;

    function techUpgradeCost(uint256 currentLevel, S.ERC20s memory cost) internal pure returns (S.ERC20s memory) {
        uint256 multiplier = 1 << currentLevel; // equivalent to 2 ** currentLevel

        S.ERC20s memory _cost;
        _cost.steel = cost.steel * multiplier;
        _cost.quartz = cost.quartz * multiplier;
        _cost.tritium = cost.tritium * multiplier;

        return _cost;
    }

    function energyInnovationRequirements(uint256 labLevel) internal pure {
        require(labLevel >= 1, "Level 1 Lab req");
    }

    function digitalSystemsRequirements(uint256 labLevel) internal pure {
        require(labLevel >= 1, "Level 1 Lab req");
    }

    function beamTechnologyRequirements(uint256 labLevel, S.Techs memory techs) internal pure {
        require(labLevel >= 1, "Level 1 Lab req");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation req");
    }

    function armourRequirements(uint256 labLevel) internal pure {
        require(labLevel >= 2, "Level 2 Lab req");
    }

    function ionSystemsRequirements(uint256 labLevel, S.Techs memory techs) internal pure {
        require(labLevel >= 4, "Level 4 Lab req");
        require(techs.beamTechnology >= 5, "Level 5 Beam tech req");
        require(techs.energyInnovation >= 4, "Level 4 Energy Innovation  req");
    }

    function plasmaEngineeringRequirements(uint256 labLevel, S.Techs memory techs) internal pure {
        require(labLevel >= 4, "Level 4 Lab req");
        require(techs.beamTechnology >= 10, "Level 10 Beam Tech req");
        require(techs.energyInnovation >= 8, "Level 8 Energy Innovation  req");
        require(techs.spacetimeWarp >= 5, "Level 5 Spacetime Warp req");
    }

    function armsDevelopmentRequirements(uint256 labLevel) internal pure {
        require(labLevel >= 4, "Level 4 Lab req");
    }

    function shieldTechRequirements(uint256 labLevel, S.Techs memory techs) internal pure {
        require(labLevel >= 6, "Level 6 Lab req");
        require(techs.energyInnovation >= 6, "Level 6 Energy Innovation  req");
    }

    function spacetimeWarpRequirements(uint256 labLevel, S.Techs memory techs) internal pure {
        require(labLevel >= 7, "Level 7 Lab req");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  req");
        require(techs.shieldTech >= 5, "Level 5 Shield Tech req");
    }

    function combustiveDriveRequirements(uint256 labLevel, S.Techs memory techs) internal pure {
        require(labLevel >= 1, "Level 1 Lab req");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation  req");
    }

    function thrustPropulsionRequirements(uint256 labLevel, S.Techs memory techs) internal pure {
        require(labLevel >= 2, "Level 2 Lab req");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation  req");
    }

    function warpDriveRequirements(uint256 labLevel, S.Techs memory techs) internal pure {
        require(labLevel >= 7, "Level 7 Lab req");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  req");
        require(techs.spacetimeWarp >= 3, "Level 3 Spacetime Warp req");
    }

    function techCost(uint256 id) internal pure returns (S.ERC20s memory) {
        S.ERC20s memory cost;
        if (id == ID.ENERGY_INNOVATION) {
            cost.quartz = 800;
            cost.tritium = 400;
        } else if (id == ID.DIGITAL_SYSTEMS) {
            cost.quartz = 400;
            cost.tritium = 600;
        } else if (id == ID.BEAM_TECHNOLOGY) {
            cost.quartz = 800;
            cost.tritium = 400;
        } else if (id == ID.ION_SYSTEMS) {
            cost.steel = 1000;
            cost.quartz = 300;
            cost.tritium = 1000;
        } else if (id == ID.PLASMA_ENGINEERING) {
            cost.steel = 2000;
            cost.quartz = 4000;
            cost.tritium = 1000;
        } else if (id == ID.SPACETIME_WARP) {
            cost.quartz = 4000;
            cost.tritium = 2000;
        } else if (id == ID.COMBUSTIVE_DRIVE) {
            cost.steel = 400;
            cost.tritium = 600;
        } else if (id == ID.THRUST_PROPULSION) {
            cost.steel = 2000;
            cost.quartz = 4000;
            cost.tritium = 600;
        } else if (id == ID.WARP_DRIVE) {
            cost.steel = 10000;
            cost.quartz = 2000;
            cost.tritium = 6000;
        } else if (id == ID.ARMOUR_INNOVATION) {
            cost.steel = 1000;
        } else if (id == ID.ARMS_DEVELOPMENT) {
            cost.steel = 800;
            cost.quartz = 200;
        } else if (id == ID.SHIELD_TECH) {
            cost.steel = 200;
            cost.quartz = 600;
        }
        return cost;
    }

    function _techsCost(S.Techs memory techs) internal pure returns (S.TechsCost memory) {
        S.TechsCost memory cost;
        cost.energyInnovation = techUpgradeCost(techs.energyInnovation, techCost(ID.ENERGY_INNOVATION));
        cost.digitalSystems = techUpgradeCost(techs.digitalSystems, techCost(ID.DIGITAL_SYSTEMS));
        cost.beamTechnology = techUpgradeCost(techs.beamTechnology, techCost(ID.BEAM_TECHNOLOGY));
        cost.armourInnovation = techUpgradeCost(techs.armourInnovation, techCost(ID.ARMOUR_INNOVATION));
        cost.ionSystems = techUpgradeCost(techs.ionSystems, techCost(ID.ION_SYSTEMS));
        cost.plasmaEngineering = techUpgradeCost(techs.plasmaEngineering, techCost(ID.PLASMA_ENGINEERING));
        cost.armsDevelopment = techUpgradeCost(techs.armsDevelopment, techCost(ID.ARMS_DEVELOPMENT));
        cost.shieldTech = techUpgradeCost(techs.shieldTech, techCost(ID.SHIELD_TECH));
        cost.spacetimeWarp = techUpgradeCost(techs.spacetimeWarp, techCost(ID.SPACETIME_WARP));
        cost.combustiveDrive = techUpgradeCost(techs.combustiveDrive, techCost(ID.COMBUSTIVE_DRIVE));
        cost.thrustPropulsion = techUpgradeCost(techs.thrustPropulsion, techCost(ID.THRUST_PROPULSION));
        cost.warpDrive = techUpgradeCost(techs.warpDrive, techCost(ID.WARP_DRIVE));
        return cost;
    }
}
