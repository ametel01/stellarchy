// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs as S} from "./libraries/Structs.sol";

contract Defences {
    mapping(uint256 => uint256) internal blasterAvailable;

    mapping(uint256 => uint256) internal beamAvailable;

    mapping(uint256 => uint256) internal astralLauncherAvailable;

    mapping(uint256 => uint256) internal plasmaAvailable;

    function defencesCost(
        uint256 quantity,
        S.ERC20s memory _cost
    ) internal pure returns (S.ERC20s memory) {
        S.ERC20s memory cost;
        cost.steel = _cost.steel * quantity;
        cost.quartz = _cost.quartz * quantity;
        cost.tritium = _cost.tritium * quantity;
        return cost;
    }

    function blasterRequirements(uint256 dockyardLevel) internal pure {
        require(dockyardLevel >= 1, "Level 1 Dockyard is required");
    }

    function beamRequirements(
        uint256 dockyardLevel,
        S.Techs memory techs
    ) internal pure {
        require(dockyardLevel >= 2, "Level 2 Dockyard is required");
        require(techs.energyInnovation >= 2, "Level 2 Energy tech required");
        require(techs.beamTechnology >= 3, "Level 3 Beam Tech required");
    }

    function astralLauncherRequirements(
        uint256 dockyardLevel,
        S.Techs memory techs
    ) internal pure {
        require(dockyardLevel >= 6, "Level 6 Dockyard is required");
        require(techs.energyInnovation >= 6, "Level 6 Energy tech required");
        require(techs.armourInnovation >= 3, "Level 3 Armour tech required");
        require(techs.shieldTech >= 1, "Level 1 Shield Tech required");
    }

    function plasmaProjectorRequirements(
        uint256 dockyardLevel,
        S.Techs memory techs
    ) internal pure {
        require(dockyardLevel >= 8, "Level 8 Dockyard is required");
        require(techs.plasmaEngineering >= 7, "Level 7 Plasma tech required");
    }

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
