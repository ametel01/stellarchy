// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../tokens/STERC20.sol";
import "../tokens/STERC721.sol";

contract Structs {
    struct ERC20s {
        uint256 steel;
        uint256 quartz;
        uint256 tritium;
    }

    struct Techs {
        uint256 energyInnovation;
        uint256 digitalSystems;
        uint256 beamTechnology;
        uint256 armourInnovation;
        uint256 ionSystems;
        uint256 plasmaEngineering;
        uint256 stellarPhysics;
        uint256 armsDevelopment;
        uint256 shieldTech;
        uint256 spacetimeWarp;
        uint256 combustiveEngine;
        uint256 thrustPropulsion;
        uint256 warpDrive;
    }

    struct Tokens {
        address erc721;
        address steel;
        address quartz;
        address tritium;
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

    struct Interfaces {
        ISTERC721 erc721;
        ISTERC20 steel;
        ISTERC20 quartz;
        ISTERC20 tritium;
    }
}
