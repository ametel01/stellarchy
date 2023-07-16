// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs} from "./libraries/Structs.sol";

contract Dockyard {
    mapping(uint256 => uint256) public carrierAvailable;

    mapping(uint256 => uint256) public scraperAvailable;

    mapping(uint256 => uint256) public celestiaAvailable;

    mapping(uint256 => uint256) public sparrowAvailable;

    mapping(uint256 => uint256) public frigateAvailable;

    mapping(uint256 => uint256) public armadeAvailable;

    function getShipsCost(
        uint256 quantity,
        uint256 _steel,
        uint256 _quartz,
        uint256 _tritium
    ) public pure returns (Structs.ERC20s memory) {
        Structs.ERC20s memory cost;
        cost.steel = _steel * quantity;
        cost.quartz = _quartz * quantity;
        cost.tritium = _tritium * quantity;
        return (cost);
    }

    function carrierRequirements(
        uint256 dockyardLevel,
        Structs.Techs memory techs
    ) public pure {
        require(dockyardLevel >= 2, "Level 2 Dockyard is req");
        require(techs.combustiveDrive >= 2, "Level 2 Combustive Engine req");
    }

    function celestiaRequirements(
        uint256 dockyardLevel,
        Structs.Techs memory techs
    ) public pure {
        require(dockyardLevel >= 1, "Level 1 Dockyard is req");
        require(techs.combustiveDrive >= 1, "Level 1 Combustive Drive req");
    }

    function scraperRequirements(
        uint256 dockyardLevel,
        Structs.Techs memory techs
    ) public pure {
        require(dockyardLevel >= 4, "Level 4 Dockyard is req");
        require(techs.combustiveDrive >= 6, "Level 6 Combustive Engine req");
        require(techs.shieldTech >= 2, "Level 2 Shield Tech req");
    }

    function sparrowRequirements(uint256 dockyardLevel) public pure {
        require(dockyardLevel >= 2, "Level 2 Dockyard is req");
    }

    function frigateRequirements(
        uint256 dockyardLevel,
        Structs.Techs memory techs
    ) public pure {
        require(dockyardLevel >= 5, "Level 5 Dockyard is req");
        require(techs.ionSystems >= 2, "Level 2 Ion Systems req");
        require(techs.thrustPropulsion >= 4, "Level 4 Thrust prop req");
    }

    function armadeRequirements(
        uint256 dockyardLevel,
        Structs.Techs memory techs
    ) public pure {
        require(dockyardLevel >= 7, "Level 7 Dockyard is req");
        require(techs.warpDrive >= 4, "Level 4 Warp Drive req");
    }
}
