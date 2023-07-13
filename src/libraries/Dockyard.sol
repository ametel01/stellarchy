// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./Structs.sol";

contract Dockyard {
    function getShipsCost(uint256 quantity, uint256 _steel, uint256 _quartz, uint256 _tritium)
        public
        pure
        returns (Structs.Cost memory)
    {
        Structs.Cost memory cost;
        cost.steel = _steel * quantity;
        cost.quartz = _quartz * quantity;
        cost.tritium = _tritium * quantity;
        return (cost);
    }

    function carrierRequirements(uint256 dockyardLevel, Structs.Techs memory techs) public pure {
        require(dockyardLevel >= 2, "Level 2 Dockyard is required");
        require(techs.combustiveEngine >= 2, "Level 2 Combustive Engine required");
    }

    function scraperRequirements(uint256 dockyardLevel, Structs.Techs memory techs) public pure {
        require(dockyardLevel >= 4, "Level 4 Dockyard is required");
        require(techs.combustiveEngine >= 6, "Level 6 Combustive Engine required");
        require(techs.shieldTech >= 2, "Level 2 Shield Tech required");
    }

    function celestiaRequirements(uint256 dockyardLevel, Structs.Techs memory techs) public pure {
        require(dockyardLevel >= 1, "Level 1 Dockyard is required");
        require(techs.combustiveEngine >= 1, "Level 1 Combustive Engine required");
    }

    function sparrowRequirements(uint256 dockyardLevel) public pure {
        require(dockyardLevel >= 1, "Level 1 Dockyard is required");
    }

    function frigateRequirements(uint256 dockyardLevel, Structs.Techs memory techs) public pure {
        require(dockyardLevel >= 5, "Level 5 Dockyard is required");
        require(techs.ionSystems >= 2, "Level 2 Ion Systems required");
        require(techs.thrustPropulsion >= 4, "Level 4 Thrust Propulsion required");
    }

    function armadeRequirements(uint256 dockyardLevel, Structs.Techs memory techs) public pure {
        require(dockyardLevel >= 7, "Level 7 Dockyard is required");
        require(techs.warpDrive >= 4, "Level 4 Warp Drive required");
    }
}
