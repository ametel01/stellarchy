// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./libraries/Mines.sol";
import "./libraries/Structs.sol";
import "./libraries/Compounds.sol";

contract NoGame is Mines, Compounds {
    uint256 numberOfPlanets;
    mapping(uint256 => uint256) resourcesSpent;
    address erc721Address;
    address steelAddress;
    address quartzAddress;
    address tritiumAddress;
    mapping(uint256 => uint256) steelMineLevel;
    mapping(uint256 => uint256) quartzMineLevel;
    mapping(uint256 => uint256) tritiumMineLevel;
    mapping(uint256 => uint256) energyPlantLevel;
    mapping(uint256 => uint256) dockyardLevel;
    mapping(uint256 => uint256) labLevel;
    mapping(uint256 => uint256) resourcesTimer;
    mapping(uint256 => uint256) energyInnovationLevel;
    mapping(uint256 => uint256) digitalSystemsLevel;
    mapping(uint256 => uint256) beamTechnologyLevel;
    mapping(uint256 => uint256) armourInnovationLevel;
    mapping(uint256 => uint256) ionSystemsLevel;
    mapping(uint256 => uint256) plasmaEngineeringLevel;
    mapping(uint256 => uint256) stellarPhysicsLevel;
    mapping(uint256 => uint256) armsDevelopmentLevel;
    mapping(uint256 => uint256) shieldTechLevel;
    mapping(uint256 => uint256) spacetimeWarpLevel;
    mapping(uint256 => uint256) combustiveDriveLevel;
    mapping(uint256 => uint256) thrustPropulsionLevel;
    mapping(uint256 => uint256) warpDriveLevel;
    mapping(uint256 => uint256) carrierAvailable;
    mapping(uint256 => uint256) scraperAvailable;
    mapping(uint256 => uint256) celestiaAvailable;
    mapping(uint256 => uint256) sparrowAvailable;
    mapping(uint256 => uint256) frigateAvailable;
    mapping(uint256 => uint256) armadeAvailable;
    mapping(uint256 => uint256) blasterAvailable;
    mapping(uint256 => uint256) beamAvailable;
    mapping(uint256 => uint256) astralLauncherAvailable;
    mapping(uint256 => uint256) plasmaBeamAvailable;

    constructor(address erc721, address steel, address quartz, address tritium) {
        erc721Address = erc721;
        steelAddress = steel;
        quartzAddress = quartz;
        tritiumAddress = tritium;
    }

    function getTokenAddresses() public view returns (Structs.Tokens memory) {
        Structs.Tokens memory tokens;
        tokens.erc721 = erc721Address;
        tokens.steel = steelAddress;
        tokens.quartz = quartzAddress;
        tokens.tritium = tritiumAddress;
        return tokens;
    }

    function getNumberOfPlanets() public view returns (uint256) {
        return numberOfPlanets;
    }

    function getPlanetPoints(uint256 planetId) public view returns (uint256) {
        return resourcesSpent[planetId] / 1000;
    }

    function getCompoundsLevels(uint256 planetId) public view returns (Structs.Compounds memory) {
        Structs.Compounds memory compounds;
        compounds.steelMine = steelMineLevel[planetId];
        compounds.quartzMine = quartzMineLevel[planetId];
        compounds.tritiumMine = tritiumMineLevel[planetId];
        compounds.energyPlant = energyPlantLevel[planetId];
        compounds.dockyard = dockyardLevel[planetId];
        compounds.lab = labLevel[planetId];
        return compounds;
    }

    function getCompoundsUpgradeCost(uint256 planetId) public view returns (Structs.CompoundsCost memory) {
        Structs.CompoundsCost memory cost;
        Structs.Compounds memory compoundsLevels = getCompoundsLevels(planetId);
        cost.steelMine = steelMineCost(compoundsLevels.steelMine);
        cost.quartzMine = quartzMineCost(compoundsLevels.quartzMine);
        cost.tritiumMine = tritiumMineCost(compoundsLevels.tritiumMine);
        cost.energyPlant = energyPlantCost(compoundsLevels.energyPlant);
        cost.dockyard = dockyardCost(compoundsLevels.dockyard);
        cost.lab = labCost(compoundsLevels.lab);
        return cost;
    }

}
