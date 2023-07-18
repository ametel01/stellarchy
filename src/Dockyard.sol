// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs as S} from "./libraries/Structs.sol";

contract Dockyard {
    mapping(uint256 => uint256) internal carrierAvailable;

    mapping(uint256 => uint256) internal scraperAvailable;

    mapping(uint256 => uint256) internal celestiaAvailable;

    mapping(uint256 => uint256) internal sparrowAvailable;

    mapping(uint256 => uint256) internal frigateAvailable;

    mapping(uint256 => uint256) internal armadeAvailable;

    function shipsCost(
        uint256 quantity,
        S.ERC20s memory _cost
    ) internal pure returns (S.ERC20s memory) {
        S.ERC20s memory cost;
        cost.steel = _cost.steel * quantity;
        cost.quartz = _cost.quartz * quantity;
        cost.tritium = _cost.tritium * quantity;
        return (cost);
    }

    function carrierRequirements(
        uint256 dockyardLevel,
        S.Techs memory techs
    ) internal pure {
        require(dockyardLevel >= 2, "Level 2 Dockyard is req");
        require(techs.combustiveDrive >= 2, "Level 2 Combustive Engine req");
    }

    function celestiaRequirements(
        uint256 dockyardLevel,
        S.Techs memory techs
    ) internal pure {
        require(dockyardLevel >= 1, "Level 1 Dockyard is req");
        require(techs.combustiveDrive >= 1, "Level 1 Combustive Drive req");
    }

    function scraperRequirements(
        uint256 dockyardLevel,
        S.Techs memory techs
    ) internal pure {
        require(dockyardLevel >= 4, "Level 4 Dockyard is req");
        require(techs.combustiveDrive >= 6, "Level 6 Combustive Engine req");
        require(techs.shieldTech >= 2, "Level 2 Shield Tech req");
    }

    function sparrowRequirements(uint256 dockyardLevel) internal pure {
        require(dockyardLevel >= 2, "Level 2 Dockyard is req");
    }

    function frigateRequirements(
        uint256 dockyardLevel,
        S.Techs memory techs
    ) internal pure {
        require(dockyardLevel >= 5, "Level 5 Dockyard is req");
        require(techs.ionSystems >= 2, "Level 2 Ion Systems req");
        require(techs.thrustPropulsion >= 4, "Level 4 Thrust prop req");
    }

    function armadeRequirements(
        uint256 dockyardLevel,
        S.Techs memory techs
    ) internal pure {
        require(dockyardLevel >= 7, "Level 7 Dockyard is req");
        require(techs.warpDrive >= 4, "Level 4 Warp Drive req");
    }

    function _shipsUnitCost() internal pure returns(S.ShipsCost memory) {
        S.ShipsCost memory costs;
        costs.carrier.steel = 4000;
        costs.carrier.quartz = 4000;

        costs.celestia.quartz = 2000;
        costs.celestia.tritium = 500;

        costs.sparrow.steel = 6000;
        costs.sparrow.quartz = 4000;
         
         costs.scraper.steel = 10000;
         costs.scraper.quartz = 6000;
         costs.scraper.tritium = 2000;

         costs.frigate.steel = 20000;
         costs.frigate.quartz = 7000;
         costs.frigate.tritium = 2000;

         costs.armade.steel = 45000;
         costs.armade.quartz = 15000;
         return costs;
    }
}

