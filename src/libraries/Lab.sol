// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs} from "./Structs.sol";

contract Lab is Structs {
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

    function getTechCost(
        uint256 currentLevel,
        uint256 steel,
        uint256 quartz,
        uint256 tritium
    ) public pure returns (ERC20s memory) {
        ERC20s memory _cost;
        _cost.steel = steel * 2 ** currentLevel;
        _cost.quartz = quartz * 2 ** currentLevel;
        _cost.tritium = tritium * 2 ** currentLevel;
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
        Techs memory techs
    ) public pure {
        require(labLevel >= 1, "Level 1 Lab req");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation req");
    }

    function armourRequirements(uint256 labLevel) public pure {
        require(labLevel >= 2, "Level 2 Lab req");
    }

    function ionSystemsRequirements(
        uint256 labLevel,
        Techs memory techs
    ) public pure {
        require(labLevel >= 4, "Level 4 Lab req");
        require(techs.beamTechnology >= 5, "Level 5 Beam tech Required");
        require(techs.energyInnovation >= 4, "Level 4 Energy Innovation  req");
    }

    function plasmaEngineeringRequirements(
        uint256 labLevel,
        Techs memory techs
    ) public pure {
        require(labLevel >= 4, "Level 4 Lab req");
        require(techs.beamTechnology >= 10, "Level 10 Beam Tech req");
        require(techs.energyInnovation >= 8, "Level 8 Energy Innovation  req");
        require(techs.spacetimeWarp >= 5, "Level 5 Spacetime Warp req");
    }

    function stellarPhysicsRequirements(
        uint256 labLevel,
        Techs memory techs
    ) public pure {
        require(labLevel >= 7, "Level 7 Lab req");
        require(techs.thrustPropulsion >= 3, "Level 10 Thrust Propulsion req");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  req");
    }

    function armsDevelopmentRequirements(uint256 labLevel) public pure {
        require(labLevel >= 4, "Level 4 Lab req");
    }

    function shieldTechRequirements(
        uint256 labLevel,
        Techs memory techs
    ) public pure {
        require(labLevel >= 6, "Level 6 Lab req");
        require(techs.energyInnovation >= 6, "Level 6 Energy Innovation  req");
    }

    function spacetimeWarpRequirements(
        uint256 labLevel,
        Techs memory techs
    ) public pure {
        require(labLevel >= 7, "Level 7 Lab req");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  req");
        require(techs.shieldTech >= 5, "Level 5 Shield Tech req");
    }

    function combustiveDriveRequirements(
        uint256 labLevel,
        Techs memory techs
    ) public pure {
        require(labLevel >= 1, "Level 1 Lab req");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation  req");
    }

    function thrustPropulsionRequirements(
        uint256 labLevel,
        Techs memory techs
    ) public pure {
        require(labLevel >= 2, "Level 2 Lab req");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation  req");
    }

    function warpDriveRequirements(
        uint256 labLevel,
        Techs memory techs
    ) public pure {
        require(labLevel >= 7, "Level 7 Lab req");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  req");
        require(techs.spacetimeWarp >= 3, "Level 3 Spacetime Warp req");
    }
}
