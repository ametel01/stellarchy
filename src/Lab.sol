// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs} from "./libraries/Structs.sol";
import {ID} from "./libraries/ID.sol";

contract Lab {
    mapping(uint256 => uint256) public energyInnovationLevel;

    mapping(uint256 => uint256) public digitalSystemsLevel;

    mapping(uint256 => uint256) public beamTechnologyLevel;

    mapping(uint256 => uint256) public armourInnovationLevel;

    mapping(uint256 => uint256) public ionSystemsLevel;

    mapping(uint256 => uint256) public plasmaEngineeringLevel;

    mapping(uint256 => uint256) public stellarPhysicsLevel;

    mapping(uint256 => uint256) public armsDevelopmentLevel;

    mapping(uint256 => uint256) public shieldTechLevel;

    mapping(uint256 => uint256) public spacetimeWarpLevel;

    mapping(uint256 => uint256) public combustiveDriveLevel;

    mapping(uint256 => uint256) public thrustPropulsionLevel;

    mapping(uint256 => uint256) public warpDriveLevel;

    function techUpgradeCost(
        uint256 currentLevel,
        Structs.ERC20s memory cost
    ) public pure returns (Structs.ERC20s memory) {
        Structs.ERC20s memory _cost;
        _cost.steel = cost.steel * 2 ** currentLevel;
        _cost.quartz = cost.quartz * 2 ** currentLevel;
        _cost.tritium = cost.tritium * 2 ** currentLevel;
        return _cost;
    }

    function energyInnovationRequirements(uint256 labLevel) public pure {
        require(labLevel >= 1, "Level 1 Lab req");
    }

    function digitalSystemsRequirements(uint256 labLevel) public pure {
        require(labLevel >= 1, "Level 1 Lab req");
    }

    function beamTechnologyRequirements(
        uint256 labLevel,
        Structs.Techs memory techs
    ) public pure {
        require(labLevel >= 1, "Level 1 Lab req");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation req");
    }

    function armourRequirements(uint256 labLevel) public pure {
        require(labLevel >= 2, "Level 2 Lab req");
    }

    function ionSystemsRequirements(
        uint256 labLevel,
        Structs.Techs memory techs
    ) public pure {
        require(labLevel >= 4, "Level 4 Lab req");
        require(techs.beamTechnology >= 5, "Level 5 Beam tech req");
        require(techs.energyInnovation >= 4, "Level 4 Energy Innovation  req");
    }

    function plasmaEngineeringRequirements(
        uint256 labLevel,
        Structs.Techs memory techs
    ) public pure {
        require(labLevel >= 4, "Level 4 Lab req");
        require(techs.beamTechnology >= 10, "Level 10 Beam Tech req");
        require(techs.energyInnovation >= 8, "Level 8 Energy Innovation  req");
        require(techs.spacetimeWarp >= 5, "Level 5 Spacetime Warp req");
    }

    function armsDevelopmentRequirements(uint256 labLevel) public pure {
        require(labLevel >= 4, "Level 4 Lab req");
    }

    function shieldTechRequirements(
        uint256 labLevel,
        Structs.Techs memory techs
    ) public pure {
        require(labLevel >= 6, "Level 6 Lab req");
        require(techs.energyInnovation >= 6, "Level 6 Energy Innovation  req");
    }

    function spacetimeWarpRequirements(
        uint256 labLevel,
        Structs.Techs memory techs
    ) public pure {
        require(labLevel >= 7, "Level 7 Lab req");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  req");
        require(techs.shieldTech >= 5, "Level 5 Shield Tech req");
    }

    function combustiveDriveRequirements(
        uint256 labLevel,
        Structs.Techs memory techs
    ) public pure {
        require(labLevel >= 1, "Level 1 Lab req");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation  req");
    }

    function thrustPropulsionRequirements(
        uint256 labLevel,
        Structs.Techs memory techs
    ) public pure {
        require(labLevel >= 2, "Level 2 Lab req");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation  req");
    }

    function warpDriveRequirements(
        uint256 labLevel,
        Structs.Techs memory techs
    ) public pure {
        require(labLevel >= 7, "Level 7 Lab req");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  req");
        require(techs.spacetimeWarp >= 3, "Level 3 Spacetime Warp req");
    }

    function techCost(uint id) public pure returns (Structs.ERC20s memory) {
        Structs.ERC20s memory cost;
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
}
