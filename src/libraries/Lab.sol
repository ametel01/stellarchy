// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./Structs.sol";

contract Lab {
    function getTechCost(uint256 currentLevel, uint256 steel, uint256 quartz, uint256 tritium)
        public
        pure
        returns (Structs.Cost memory)
    {
        Structs.Cost memory _cost;
        _cost.steel = steel * 2 ** currentLevel;
        _cost.quartz = quartz * 2 ** currentLevel;
        _cost.tritium = tritium * 2 ** currentLevel;
        return _cost;
    }

    function energyInnovationRequirements(uint256 labLevel) public pure {
        require(labLevel >= 1, "Level 1 Lab required");
    }

    function digitalSystemsRequirements(uint256 labLevel) public pure {
        require(labLevel >= 1, "Level 1 Lab required");
    }

    function beamTechnologyRequirements(uint256 labLevel, Structs.Techs memory techs) public pure {
        require(labLevel >= 1, "Level 1 Lab required");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation required");
    }

    function armourRequirements(uint256 labLevel) public pure {
        require(labLevel >= 2, "Level 2 Lab required");
    }

    function ionSystemsRequirements(uint256 labLevel, Structs.Techs memory techs) public pure {
        require(labLevel >= 4, "Level 4 Lab required");
        require(techs.beamTechnology >= 5, "Level 5 Beam tech Required");
        require(techs.energyInnovation >= 4, "Level 4 Energy Innovation  required");
    }

    function plasmaEngineeringRequirements(uint256 labLevel, Structs.Techs memory techs) public pure {
        require(labLevel >= 4, "Level 4 Lab required");
        require(techs.beamTechnology >= 10, "Level 10 Beam Tech required");
        require(techs.energyInnovation >= 8, "Level 8 Energy Innovation  required");
        require(techs.spacetimeWarp >= 5, "Level 5 Spacetime Warp required");
    }

    function stellarPhysicsRequirements(uint256 labLevel, Structs.Techs memory techs) public pure {
        require(labLevel >= 7, "Level 7 Lab required");
        require(techs.thrustPropulsion >= 3, "Level 10 Thrust Propulsion required");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  required");
    }

    function armsDevelopmentRequirements(uint256 labLevel) public pure {
        require(labLevel >= 4, "Level 4 Lab required");
    }

    function shieldTechRequirements(uint256 labLevel, Structs.Techs memory techs) public pure {
        require(labLevel >= 6, "Level 6 Lab required");
        require(techs.energyInnovation >= 6, "Level 6 Energy Innovation  required");
    }

    function spacetimeWarpRequirements(uint256 labLevel, Structs.Techs memory techs) public pure {
        require(labLevel >= 7, "Level 7 Lab required");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  required");
        require(techs.shieldTech >= 5, "Level 5 Shield Tech required");
    }

    function combustiveEngineRequirements(uint256 labLevel, Structs.Techs memory techs) public pure {
        require(labLevel >= 1, "Level 1 Lab required");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation  required");
    }

    function thrustPropulsionRequirements(uint256 labLevel, Structs.Techs memory techs) public pure {
        require(labLevel >= 2, "Level 2 Lab required");
        require(techs.energyInnovation >= 1, "Level 1 Energy Innovation  required");
    }

    function warpDriveRequirements(uint256 labLevel, Structs.Techs memory techs) public pure {
        require(labLevel >= 7, "Level 7 Lab required");
        require(techs.energyInnovation >= 5, "Level 5 Energy Innovation  required");
        require(techs.spacetimeWarp >= 3, "Level 3 Spacetime Warp required");
    }
}
