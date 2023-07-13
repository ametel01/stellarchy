// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Structs {
    struct Cost {
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
        Cost steelMine;
        Cost quartzMine;
        Cost tritiumMine;
        Cost energyPlant;
        Cost dockyard;
        Cost lab;
    }
}
