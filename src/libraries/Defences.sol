// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19.0;

import {Structs} from "./Structs.sol";

contract Defences is Structs {
    mapping(uint256 => uint256) private blasterAvailable;

    mapping(uint256 => uint256) private beamAvailable;

    mapping(uint256 => uint256) private astralLauncherAvailable;

    mapping(uint256 => uint256) private plasmaBeamAvailable;

    function getDefencesCost(uint256 quantity, uint256 _steel, uint256 _quartz, uint256 _tritium)
        internal
        pure
        returns (ERC20s memory)
    {
        ERC20s memory cost;
        cost.steel = _steel * quantity;
        cost.quartz = _quartz * quantity;
        cost.tritium = _tritium * quantity;
        return (cost);
    }

    function blasterRequirements(uint256 dockyardLevel) internal pure {
        require(dockyardLevel >= 1, "Level 1 Dockyard is required");
    }

    function beamRequirements(uint256 dockyardLevel, Techs memory techs) internal pure {
        require(dockyardLevel >= 2, "Level 2 Dockyard is required");
        require(techs.energyInnovation >= 2, "Level 2 Energy tech required");
        require(techs.beamTechnology >= 3, "Level 3 Beam Tech required");
    }

    function astralLauncherRequirements(uint256 dockyardLevel, Techs memory techs) internal pure {
        require(dockyardLevel >= 6, "Level 6 Dockyard is required");
        require(techs.energyInnovation >= 6, "Level 6 Energy tech required");
        require(techs.armourInnovation >= 3, "Level 3 Armour tech required");
        require(techs.shieldTech >= 1, "Level 1 Shield Tech required");
    }

    function plasmaBeamRequirements(uint256 dockyardLevel, Techs memory techs) internal pure {
        require(dockyardLevel >= 8, "Level 8 Dockyard is required");
        require(techs.plasmaEngineering >= 7, "Level 7 Plasma tech required");
    }
}
