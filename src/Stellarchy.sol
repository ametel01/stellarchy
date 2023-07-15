// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs} from "./libraries/Structs.sol";
import {Compounds} from "./libraries/Compounds.sol";
import {Lab} from "./libraries/Lab.sol";
import {Dockyard} from "./libraries/Dockyard.sol";
import {Defences} from "./libraries/Defences.sol";
import {ISTERC20} from "./tokens/STERC20.sol";
import {ISTERC721} from "./tokens/STERC721.sol";

contract Stellarchy is Compounds, Lab, Dockyard, Defences {
    uint256 public constant PRICE = 0.01 ether;

    address payable public owner;

    uint256 private numberOfPlanets;

    mapping(uint256 => uint256) private resourcesSpent;

    address private erc721Address;

    address private steelAddress;

    address private quartzAddress;

    address private tritiumAddress;

    mapping(uint256 => uint256) private resourcesTimer;

    constructor(
        address erc721,
        address steel,
        address quartz,
        address tritium
    ) {
        _initializer(erc721, steel, quartz, tritium);
    }

    // receive() external payable {}

    // View Functions
    function getTokenAddresses() external view returns (Tokens memory tokens) {
        Tokens memory _tokens;
        _tokens.erc721 = erc721Address;
        _tokens.steel = steelAddress;
        _tokens.quartz = quartzAddress;
        _tokens.tritium = tritiumAddress;
        return _tokens;
    }

    function getNumberOfPlanets() external view returns (uint256 nPlanets) {
        return numberOfPlanets;
    }

    function getPlanetPoints(
        uint256 planetId
    ) external view returns (uint256 points) {
        return resourcesSpent[planetId] / 1000;
    }

    function getCompoundsLevels(
        uint256 planetId
    ) public view returns (Compounds memory levels) {
        return _compoundsLevels(planetId);
    }

    function getCompoundsUpgradeCost(
        uint256 planetId
    ) external view returns (CompoundsCost memory cost) {
        CompoundsCost memory _cost;
        _cost.steelMine = steelMineCost(steelMineLevel[planetId]);
        _cost.quartzMine = quartzMineCost(quartzMineLevel[planetId]);
        _cost.tritiumMine = tritiumMineCost(tritiumMineLevel[planetId]);
        _cost.energyPlant = energyPlantCost(energyPlantLevel[planetId]);
        _cost.dockyard = dockyardCost(dockyardLevel[planetId]);
        _cost.lab = labCost(labLevel[planetId]);
        return _cost;
    }

    function getSpendableResources(
        uint256 planetId
    ) external view returns (ERC20s memory resurces) {
        Interfaces memory interfaces = _getInterfaces();
        ERC20s memory amounts;
        address account = interfaces.erc721.ownerOf(planetId);
        amounts.steel = interfaces.steel.balanceOf(account);
        amounts.quartz = interfaces.quartz.balanceOf(account);
        amounts.tritium = interfaces.tritium.balanceOf(account);
        return amounts;
    }

    function getCollectibleResources(
        uint256 planetId
    ) public view returns (ERC20s memory resources) {
        ERC20s memory _resources;
        uint256 timeElapsed = _timeSinceLastCollection(planetId);
        _resources.steel =
            (_steelProduction(steelMineLevel[planetId]) * timeElapsed) /
            3600;
        _resources.quartz =
            (_quartzProduction(quartzMineLevel[planetId]) * timeElapsed) /
            3600;
        _resources.tritium =
            (_tritiumProduction(tritiumMineLevel[planetId]) * timeElapsed) /
            3600;
        return _resources;
    }

    function getEnergyAvailable(
        uint256 planetId
    ) external view returns (int256) {
        Compounds memory mines = getCompoundsLevels(planetId);
        uint256 grossProduction = energyPlantProduction(
            energyPlantLevel[planetId]
        );
        int256 energyRequired = _calculateEnergyConsumption(mines);
        return int256(grossProduction) - energyRequired;
    }

    // External Functions
    function generatePlanet() external payable {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        require(erc721.balanceOf(msg.sender) == 0, "MAX_PLANET_PER_ADDRESS");
        require(msg.value >= PRICE, "NOT_ENOUGH_ETHER");
        erc721.mint(msg.sender, numberOfPlanets + 1);
        numberOfPlanets += 1;
        _mintInitialLiquidity(msg.sender);
    }

    function collectResources() public {
        uint256 planetId = _getTokenOwner(msg.sender);
        ERC20s memory amounts = getCollectibleResources(planetId);
        _recieveResourcesERC20(msg.sender, amounts);
        resourcesTimer[planetId] = block.timestamp;
    }

    function steelMineUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        ERC20s memory cost = steelMineCost(steelMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        steelMineLevel[planetId] += 1;
    }

    function quartzMineUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        ERC20s memory cost = quartzMineCost(quartzMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        quartzMineLevel[planetId] += 1;
    }

    function tritiumMineUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        ERC20s memory cost = tritiumMineCost(tritiumMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        tritiumMineLevel[planetId] += 1;
    }

    function energyPlantUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        ERC20s memory cost = energyPlantCost(energyPlantLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        energyPlantLevel[planetId] += 1;
    }

    function dockyardUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        ERC20s memory cost = dockyardCost(dockyardLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        dockyardLevel[planetId] += 1;
    }

    function labUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        ERC20s memory cost = labCost(labLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        labLevel[planetId] += 1;
    }

    function energyInnovationUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        energyInnovationRequirements(labLevel[planetId]);
        ERC20s memory cost = getTechCost(
            energyInnovationLevel[planetId],
            0,
            800,
            400
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        energyInnovationLevel[planetId] += 1;
    }

    function digitalSystemsUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        digitalSystemsRequirements(labLevel[planetId]);
        ERC20s memory cost = getTechCost(
            digitalSystemsLevel[planetId],
            0,
            400,
            600
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        digitalSystemsLevel[planetId] += 1;
    }

    function beamTechnologyUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Techs memory techs = _getTechsLevels(planetId);
        beamTechnologyRequirements(labLevel[planetId], techs);
        ERC20s memory cost = getTechCost(
            beamTechnologyLevel[planetId],
            0,
            800,
            400
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        beamTechnologyLevel[planetId] += 1;
    }

    function armourInnovationUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        armourRequirements(labLevel[planetId]);
        ERC20s memory cost = getTechCost(
            armourInnovationLevel[planetId],
            1000,
            0,
            0
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        armourInnovationLevel[planetId] += 1;
    }

    function ionSystemsUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Techs memory techs = _getTechsLevels(planetId);
        ionSystemsRequirements(labLevel[planetId], techs);
        ERC20s memory cost = getTechCost(
            ionSystemsLevel[planetId],
            1000,
            300,
            1000
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        ionSystemsLevel[planetId] += 1;
    }

    function plasmaEngineeringUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Techs memory techs = _getTechsLevels(planetId);
        plasmaEngineeringRequirements(labLevel[planetId], techs);
        ERC20s memory cost = getTechCost(
            plasmaEngineeringLevel[planetId],
            2000,
            4000,
            1000
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        plasmaEngineeringLevel[planetId] += 1;
    }

    function stellarPhysicsUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Techs memory techs = _getTechsLevels(planetId);
        stellarPhysicsRequirements(labLevel[planetId], techs);
        ERC20s memory cost = getTechCost(
            stellarPhysicsLevel[planetId],
            4000,
            8000,
            4000
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        steelMineLevel[planetId] += 1;
    }

    function armsDevelopmentUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        armsDevelopmentRequirements(labLevel[planetId]);
        ERC20s memory cost = getTechCost(
            armsDevelopmentLevel[planetId],
            800,
            200,
            0
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        armsDevelopmentLevel[planetId] += 1;
    }

    function shieldTechUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Techs memory techs = _getTechsLevels(planetId);
        shieldTechRequirements(labLevel[planetId], techs);
        ERC20s memory cost = getTechCost(
            shieldTechLevel[planetId],
            200,
            600,
            0
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        shieldTechLevel[planetId] += 1;
    }

    function spacetimeWarpUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Techs memory techs = _getTechsLevels(planetId);
        spacetimeWarpRequirements(labLevel[planetId], techs);
        ERC20s memory cost = getTechCost(
            spacetimeWarpLevel[planetId],
            0,
            4000,
            2000
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        spacetimeWarpLevel[planetId] += 1;
    }

    function combustiveDriveUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Techs memory techs = _getTechsLevels(planetId);
        combustiveDriveRequirements(labLevel[planetId], techs);
        ERC20s memory cost = getTechCost(
            combustiveDriveLevel[planetId],
            400,
            0,
            600
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        combustiveDriveLevel[planetId] += 1;
    }

    function thrustPropulsionUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Techs memory techs = _getTechsLevels(planetId);
        thrustPropulsionRequirements(labLevel[planetId], techs);
        ERC20s memory cost = getTechCost(
            thrustPropulsionLevel[planetId],
            2000,
            4000,
            600
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        thrustPropulsionLevel[planetId] += 1;
    }

    function warpDriveUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Techs memory techs = _getTechsLevels(planetId);
        warpDriveRequirements(labLevel[planetId], techs);
        ERC20s memory cost = getTechCost(
            warpDriveLevel[planetId],
            10000,
            20000,
            6000
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        warpDriveLevel[planetId] += 1;
    }

    // Internal Functions
    function _initializer(
        address erc721,
        address steel,
        address quartz,
        address tritium
    ) internal virtual {
        erc721Address = erc721;
        steelAddress = steel;
        quartzAddress = quartz;
        tritiumAddress = tritium;
    }

    function _getTokenOwner(address account) internal view returns (uint256) {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        return erc721.tokenOf(account);
    }

    function _getInterfaces() internal view returns (Interfaces memory) {
        Interfaces memory interfaces;
        interfaces.erc721 = ISTERC721(erc721Address);
        interfaces.steel = ISTERC20(steelAddress);
        interfaces.quartz = ISTERC20(quartzAddress);
        interfaces.tritium = ISTERC20(tritiumAddress);
        return interfaces;
    }

    function _compoundsLevels(
        uint256 planetId
    ) internal view returns (Compounds memory) {
        Compounds memory compounds;
        compounds.steelMine = steelMineLevel[planetId];
        compounds.quartzMine = quartzMineLevel[planetId];
        compounds.tritiumMine = tritiumMineLevel[planetId];
        compounds.energyPlant = energyPlantLevel[planetId];
        compounds.dockyard = dockyardLevel[planetId];
        compounds.lab = labLevel[planetId];
        return compounds;
    }

    function _timeSinceLastCollection(
        uint256 planetId
    ) internal view returns (uint256) {
        return block.timestamp - resourcesTimer[planetId];
    }

    function _mintInitialLiquidity(address caller) internal {
        Interfaces memory interfaces = _getInterfaces();
        interfaces.steel.mint(caller, 500);
        interfaces.quartz.mint(caller, 300);
        interfaces.tritium.mint(caller, 100);
    }

    function _recieveResourcesERC20(
        address caller,
        ERC20s memory amounts
    ) internal {
        Interfaces memory interfaces = _getInterfaces();
        if (amounts.steel > 0) {
            interfaces.steel.mint(caller, amounts.steel);
        }
        if (amounts.quartz > 0) {
            interfaces.quartz.mint(caller, amounts.quartz);
        }
        if (amounts.tritium > 0) {
            interfaces.tritium.mint(caller, amounts.tritium);
        }
    }

    function _payResourcesERC20(
        address caller,
        ERC20s memory amounts
    ) internal {
        Interfaces memory interfaces = _getInterfaces();
        if (amounts.steel > 0) {
            require(
                interfaces.steel.balanceOf(caller) >= amounts.steel,
                "NOT_ENOUGH_STEEL"
            );
            interfaces.steel.burn(caller, amounts.steel);
        }
        if (amounts.quartz > 0) {
            require(
                interfaces.quartz.balanceOf(caller) >= amounts.quartz,
                "NOT_ENOUGH_QUARTZ"
            );
            interfaces.quartz.burn(caller, amounts.quartz);
        }
        if (amounts.tritium > 0) {
            require(
                interfaces.tritium.balanceOf(caller) >= amounts.tritium,
                "NOT_ENOUGH_TRITIUM"
            );
            interfaces.tritium.burn(caller, amounts.tritium);
        }
    }

    function _updateResourcesSpent(
        uint256 planetId,
        ERC20s memory cost
    ) internal {
        resourcesSpent[planetId] += (cost.steel + cost.quartz);
    }

    function _calculateEnergyConsumption(
        Compounds memory mines
    ) internal pure returns (int256) {
        return
            int256(
                baseMineConsumption(mines.steelMine) +
                    baseMineConsumption(mines.quartzMine) +
                    tritiumMineConsumption(mines.tritiumMine)
            );
    }

    function _getTechsLevels(
        uint256 planetId
    ) internal view returns (Techs memory) {
        Techs memory techs;
        techs.energyInnovation = energyInnovationLevel[planetId];
        techs.digitalSystems = digitalSystemsLevel[planetId];
        techs.beamTechnology = beamTechnologyLevel[planetId];
        techs.armourInnovation = armourInnovationLevel[planetId];
        techs.ionSystems = ionSystemsLevel[planetId];
        techs.plasmaEngineering = plasmaEngineeringLevel[planetId];
        techs.stellarPhysics = stellarPhysicsLevel[planetId];
        techs.armsDevelopment = armsDevelopmentLevel[planetId];
        techs.shieldTech = shieldTechLevel[planetId];
        techs.spacetimeWarp = spacetimeWarpLevel[planetId];
        techs.combustiveDrive = combustiveDriveLevel[planetId];
        techs.thrustPropulsion = thrustPropulsionLevel[planetId];
        techs.warpDrive = warpDriveLevel[planetId];
        return techs;
    }
}
