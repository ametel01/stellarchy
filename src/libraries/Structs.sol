// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {ISTERC20} from "../tokens/STERC20.sol";
import {ISTERC721} from "../tokens/STERC721.sol";

library Structs {
    struct ERC20s {
        uint256 steel;
        uint256 quartz;
        uint256 tritium;
    }

    struct Compounds {
        uint256 steelMine;
        uint256 quartzMine;
        uint256 tritiumMine;
        uint256 energyPlant;
        uint256 dockyard;
        uint256 lab;
    }

    struct CompoundsCost {
        ERC20s steelMine;
        ERC20s quartzMine;
        ERC20s tritiumMine;
        ERC20s energyPlant;
        ERC20s dockyard;
        ERC20s lab;
    }

    struct Techs {
        uint256 energyInnovation;
        uint256 digitalSystems;
        uint256 beamTechnology;
        uint256 ionSystems;
        uint256 plasmaEngineering;
        uint256 spacetimeWarp;
        uint256 combustiveDrive;
        uint256 thrustPropulsion;
        uint256 warpDrive;
        uint256 armourInnovation;
        uint256 armsDevelopment;
        uint256 shieldTech;
    }

    struct TechsCost {
        ERC20s energyInnovation;
        ERC20s digitalSystems;
        ERC20s beamTechnology;
        ERC20s ionSystems;
        ERC20s plasmaEngineering;
        ERC20s spacetimeWarp;
        ERC20s combustiveDrive;
        ERC20s thrustPropulsion;
        ERC20s warpDrive;
        ERC20s armourInnovation;
        ERC20s armsDevelopment;
        ERC20s shieldTech;
    }

    struct ShipsLevels {
        uint256 carrier;
        uint256 celestia;
        uint256 scraper;
        uint256 sparrow;
        uint256 frigate;
        uint256 armade;
    }

    struct ShipsCost {
        ERC20s carrier;
        ERC20s celestia;
        ERC20s scraper;
        ERC20s sparrow;
        ERC20s frigate;
        ERC20s armade;
    }

    struct DefencesLevels {
        uint256 blaster;
        uint256 beam;
        uint256 astralLauncher;
        uint256 plasmaProjector;
    }

    struct DefencesCost {
        ERC20s blaster;
        ERC20s beam;
        ERC20s astralLauncher;
        ERC20s plasmaProjector;
    }

    struct Tokens {
        address erc721;
        address steel;
        address quartz;
        address tritium;
    }

    struct Interfaces {
        ISTERC721 erc721;
        ISTERC20 steel;
        ISTERC20 quartz;
        ISTERC20 tritium;
    }

    struct EnergyCost {
        uint256 steelMine;
        uint256 quartzMine;
        uint256 tritiumMine;
    }
}
