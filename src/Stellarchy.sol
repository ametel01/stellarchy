// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {Structs as S} from "./libraries/Structs.sol";
import {Compounds} from "./Compounds.sol";
import {ID} from "./libraries/ID.sol";
import {Lab} from "./Lab.sol";
import {Dockyard} from "./Dockyard.sol";
import {Defences} from "./Defences.sol";
import {ISTERC20} from "./tokens/STERC20.sol";
import {ISTERC721} from "./tokens/STERC721.sol";

contract Stellarchy is Ownable, Compounds, Lab, Dockyard, Defences {
    uint256 private constant E18 = 10 ** 18;

    uint256 public constant PRICE = 0.01 ether;

    address payable private _receiver;

    uint256 private numberOfPlanets;

    mapping(uint256 => uint256) private resourcesSpent;

    address private erc721Address;

    address private steelAddress;

    address private quartzAddress;

    address private tritiumAddress;

    mapping(uint256 => uint256) private _resourcesTimer;

    constructor() {
        _receiver = payable(msg.sender);
    }

    receive() external payable {}

    function _initializer(address erc721, address steel, address quartz, address tritium) external onlyOwner {
        erc721Address = erc721;
        steelAddress = steel;
        quartzAddress = quartz;
        tritiumAddress = tritium;
    }

    function withdraw() public {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success,) = _receiver.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function generatePlanet() external payable {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        require(erc721.balanceOf(msg.sender) == 0, "MAX_PLANET_PER_ADDRESS");
        require(msg.value >= PRICE, "NOT_ENOUGH_ETHER");
        erc721.mint(msg.sender, numberOfPlanets + 1);
        numberOfPlanets += 1;
        _resourcesTimer[numberOfPlanets + 1] = block.timestamp;
        _mintInitialLiquidity(msg.sender);
    }

    function steelMineUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _steelMineCost(steelMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        steelMineLevel[planetId] += 1;
    }

    function quartzMineUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _quartzMineCost(quartzMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        quartzMineLevel[planetId] += 1;
    }

    function tritiumMineUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _tritiumMineCost(tritiumMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        tritiumMineLevel[planetId] += 1;
    }

    function energyPlantUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _energyPlantCost(energyPlantLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        energyPlantLevel[planetId] += 1;
    }

    function dockyardUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _dockyardCost(dockyardLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        dockyardLevel[planetId] += 1;
    }

    function labUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _labCost(labLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        labLevel[planetId] += 1;
    }

    function energyInnovationUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        energyInnovationRequirements(labLevel[planetId]);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(energyInnovationLevel[planetId], techsCosts.energyInnovation);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        energyInnovationLevel[planetId] += 1;
    }

    function digitalSystemsUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        digitalSystemsRequirements(labLevel[planetId]);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(digitalSystemsLevel[planetId], techsCosts.digitalSystems);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        digitalSystemsLevel[planetId] += 1;
    }

    function beamTechnologyUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        beamTechnologyRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(beamTechnologyLevel[planetId], techsCosts.beamTechnology);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        beamTechnologyLevel[planetId] += 1;
    }

    function ionSystemsUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        ionSystemsRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(ionSystemsLevel[planetId], techsCosts.ionSystems);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        ionSystemsLevel[planetId] += 1;
    }

    function plasmaEngineeringUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        plasmaEngineeringRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(plasmaEngineeringLevel[planetId], techsCosts.plasmaEngineering);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        plasmaEngineeringLevel[planetId] += 1;
    }

    function spacetimeWarpUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        spacetimeWarpRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(spacetimeWarpLevel[planetId], techsCosts.spacetimeWarp);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        spacetimeWarpLevel[planetId] += 1;
    }

    function combustionDriveUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        combustiveDriveRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(combustiveDriveLevel[planetId], techsCosts.combustiveDrive);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        combustiveDriveLevel[planetId] += 1;
    }

    function thrustPropulsionUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        thrustPropulsionRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(thrustPropulsionLevel[planetId], techsCosts.thrustPropulsion);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        thrustPropulsionLevel[planetId] += 1;
    }

    function warpDriveUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        warpDriveRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(warpDriveLevel[planetId], techsCosts.warpDrive);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        warpDriveLevel[planetId] += 1;
    }

    function armourInnovationUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        armourRequirements(labLevel[planetId]);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(armourInnovationLevel[planetId], techsCosts.armourInnovation);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        armourInnovationLevel[planetId] += 1;
    }

    function weaponsDevelopmentUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        armsDevelopmentRequirements(labLevel[planetId]);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(armsDevelopmentLevel[planetId], techsCosts.armsDevelopment);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        armsDevelopmentLevel[planetId] += 1;
    }

    function shieldTechUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        shieldTechRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(shieldTechLevel[planetId], techsCosts.shieldTech);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        shieldTechLevel[planetId] += 1;
    }

    function carrierBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        carrierRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.carrier);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        carrierAvailable[planetId] += amount;
    }

    function celestiaBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        celestiaRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.celestia);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        celestiaAvailable[planetId] += amount;
    }

    function sparrowBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        sparrowRequirements(dockyardLevel[planetId]);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.sparrow);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        sparrowAvailable[planetId] += amount;
    }

    function scraperBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        scraperRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.scraper);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        scraperAvailable[planetId] += amount;
    }

    function frigateBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        frigateRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.frigate);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        frigateAvailable[planetId] += amount;
    }

    function armadeBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        armadeRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.carrier);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        armadeAvailable[planetId] += amount;
    }

    function blasterBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        blasterRequirements(dockyardLevel[planetId]);
        S.DefencesCost memory unitsCost = _defencesUnitCost();
        S.ERC20s memory cost = defencesCost(amount, unitsCost.blaster);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        blasterAvailable[planetId] += amount;
    }

    function beamBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        beamRequirements(dockyardLevel[planetId], techs);
        S.DefencesCost memory unitsCost = _defencesUnitCost();
        S.ERC20s memory cost = defencesCost(amount, unitsCost.beam);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        beamAvailable[planetId] += amount;
    }

    function astralLauncherBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        astralLauncherRequirements(dockyardLevel[planetId], techs);
        S.DefencesCost memory unitsCost = _defencesUnitCost();
        S.ERC20s memory cost = defencesCost(amount, unitsCost.astralLauncher);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        astralLauncherAvailable[planetId] += amount;
    }

    function plasmaProjectorBuild(uint32 amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        plasmaProjectorRequirements(dockyardLevel[planetId], techs);
        S.DefencesCost memory unitsCost = _defencesUnitCost();
        S.ERC20s memory cost = defencesCost(amount, unitsCost.plasmaProjector);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        plasmaAvailable[planetId] += amount;
    }

    function collectResources() public {
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory amounts = getCollectibleResources(planetId);
        _recieveResourcesERC20(msg.sender, amounts);
        _resourcesTimer[planetId] = block.timestamp;
    }

    function getPrizePoll() external view returns (uint) {
        return address(this).balance / 2;
    }

    function getTokenAddresses() external view returns (S.Tokens memory tokens) {
        S.Tokens memory _tokens;
        _tokens.erc721 = erc721Address;
        _tokens.steel = steelAddress;
        _tokens.quartz = quartzAddress;
        _tokens.tritium = tritiumAddress;
        return _tokens;
    }

    function getNumberOfPlanets() external view returns (uint256 nPlanets) {
        return numberOfPlanets;
    }

    function getPlanetPoints(uint256 planetId) external view returns (uint256 points) {
        return resourcesSpent[planetId] / 1000;
    }

    function getSpendableResources(uint256 planetId) external view returns (S.ERC20s memory) {
        S.Interfaces memory interfaces = _getInterfaces();
        address planetOwner = interfaces.erc721.ownerOf(planetId);
        S.ERC20s memory amounts;
        amounts.steel = (interfaces.steel.balanceOf(planetOwner) / E18);
        amounts.quartz = (interfaces.quartz.balanceOf(planetOwner) / E18);
        amounts.tritium = (interfaces.tritium.balanceOf(planetOwner) / E18);
        return amounts;
    }

    function getCollectibleResources(uint256 planetId) public view returns (S.ERC20s memory) {
        S.ERC20s memory _resources;
        uint256 timeElapsed = _timeSinceLastCollection(planetId);
        _resources.steel = _steelProduction(steelMineLevel[planetId]) * timeElapsed / 3600;
        _resources.quartz = _quartzProduction(quartzMineLevel[planetId]) * timeElapsed / 3600;
        _resources.tritium = _tritiumProduction(tritiumMineLevel[planetId]) * timeElapsed / 3600;
        return _resources;
    }

    function getEnergyAvailable(uint256 planetId) external view returns (int256) {
        S.Compounds memory mines = getCompoundsLevels(planetId);
        int256 grossProduction = int256(_energyPlantProduction(energyPlantLevel[planetId]));
        int256 celestiaProduction = int256(celestiaAvailable[planetId] * 15);
        int256 energyRequired = int256(_calculateEnergyConsumption(mines));
        return grossProduction + celestiaProduction - energyRequired;
    }

    function getCompoundsLevels(uint256 planetId) public view returns (S.Compounds memory levels) {
        S.Compounds memory compounds;
        compounds.steelMine = steelMineLevel[planetId];
        compounds.quartzMine = quartzMineLevel[planetId];
        compounds.tritiumMine = tritiumMineLevel[planetId];
        compounds.energyPlant = energyPlantLevel[planetId];
        compounds.dockyard = dockyardLevel[planetId];
        compounds.lab = labLevel[planetId];
        return compounds;
    }

    function getCompoundsUpgradeCost(uint256 planetId) external view returns (S.CompoundsCost memory) {
        S.CompoundsCost memory _cost;
        _cost.steelMine = _steelMineCost(steelMineLevel[planetId]);
        _cost.quartzMine = _quartzMineCost(quartzMineLevel[planetId]);
        _cost.tritiumMine = _tritiumMineCost(tritiumMineLevel[planetId]);
        _cost.energyPlant = _energyPlantCost(energyPlantLevel[planetId]);
        _cost.dockyard = _dockyardCost(dockyardLevel[planetId]);
        _cost.lab = _labCost(labLevel[planetId]);
        return _cost;
    }

    function getTechsLevels(uint256 planetId) public view returns (S.Techs memory) {
        S.Techs memory techs;
        techs.energyInnovation = energyInnovationLevel[planetId];
        techs.digitalSystems = digitalSystemsLevel[planetId];
        techs.beamTechnology = beamTechnologyLevel[planetId];
        techs.armourInnovation = armourInnovationLevel[planetId];
        techs.ionSystems = ionSystemsLevel[planetId];
        techs.plasmaEngineering = plasmaEngineeringLevel[planetId];
        techs.armsDevelopment = armsDevelopmentLevel[planetId];
        techs.shieldTech = shieldTechLevel[planetId];
        techs.spacetimeWarp = spacetimeWarpLevel[planetId];
        techs.combustiveDrive = combustiveDriveLevel[planetId];
        techs.thrustPropulsion = thrustPropulsionLevel[planetId];
        techs.warpDrive = warpDriveLevel[planetId];
        return techs;
    }

    function getTechsUpgradeCosts() public view returns (S.TechsCost memory) {
        S.Interfaces memory interfaces = _getInterfaces();
        uint256 planetId = interfaces.erc721.tokenOf(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        return _techsCost(techs);
    }

    function getShipsLevels(uint256 planetId) external view returns (S.ShipsLevels memory) {
        S.ShipsLevels memory ships;
        ships.carrier = carrierAvailable[planetId];
        ships.celestia = celestiaAvailable[planetId];
        ships.scraper = scraperAvailable[planetId];
        ships.sparrow = sparrowAvailable[planetId];
        ships.frigate = frigateAvailable[planetId];
        ships.armade = armadeAvailable[planetId];
        return ships;
    }

    function getShipsCost() external pure returns (S.ShipsCost memory) {
        return _shipsUnitCost();
    }

    function getDefencesLevels(uint256 planetId) external view returns (S.DefencesLevels memory) {
        S.DefencesLevels memory defences;
        defences.blaster = blasterAvailable[planetId];
        defences.beam = beamAvailable[planetId];
        defences.astralLauncher = astralLauncherAvailable[planetId];
        defences.plasmaProjector = plasmaAvailable[planetId];
        return defences;
    }

    function getDefencesCost() external pure returns (S.DefencesCost memory) {
        return _defencesUnitCost();
    }

    function _getTokenOwner(address account) private view returns (uint256) {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        return erc721.tokenOf(account);
    }

    function _getInterfaces() private view returns (S.Interfaces memory) {
        S.Interfaces memory interfaces;
        interfaces.erc721 = ISTERC721(erc721Address);
        interfaces.steel = ISTERC20(steelAddress);
        interfaces.quartz = ISTERC20(quartzAddress);
        interfaces.tritium = ISTERC20(tritiumAddress);
        return interfaces;
    }

    function _timeSinceLastCollection(uint256 planetId) private view returns (uint256) {
        return block.timestamp - _resourcesTimer[planetId];
    }

    function _mintInitialLiquidity(address caller) private {
        S.Interfaces memory interfaces = _getInterfaces();
        interfaces.steel.mint(caller, 500 * E18);
        interfaces.quartz.mint(caller, 300 * E18);
        interfaces.tritium.mint(caller, 100 * E18);
    }

    function _recieveResourcesERC20(address caller, S.ERC20s memory amounts) private {
        S.Interfaces memory interfaces = _getInterfaces();
        if (amounts.steel > 0) {
            interfaces.steel.mint(caller, amounts.steel * E18);
        }
        if (amounts.quartz > 0) {
            interfaces.quartz.mint(caller, amounts.quartz * E18);
        }
        if (amounts.tritium > 0) {
            interfaces.tritium.mint(caller, amounts.tritium * E18);
        }
    }

    function _payResourcesERC20(address caller, S.ERC20s memory amounts) private {
        S.Interfaces memory interfaces = _getInterfaces();
        if (amounts.steel > 0) {
            require(interfaces.steel.balanceOf(caller) >= amounts.steel, "NOT_ENOUGH_STEEL");
            interfaces.steel.burn(caller, amounts.steel * E18);
        }
        if (amounts.quartz > 0) {
            require(interfaces.quartz.balanceOf(caller) >= amounts.quartz, "NOT_ENOUGH_QUARTZ");
            interfaces.quartz.burn(caller, amounts.quartz * E18);
        }
        if (amounts.tritium > 0) {
            require(interfaces.tritium.balanceOf(caller) >= amounts.tritium, "NOT_ENOUGH_TRITIUM");
            interfaces.tritium.burn(caller, amounts.tritium * E18);
        }
    }

    function _updateResourcesSpent(uint256 planetId, S.ERC20s memory cost) private {
        resourcesSpent[planetId] += (cost.steel + cost.quartz);
    }

    function _calculateEnergyConsumption(S.Compounds memory mines) private pure returns (uint256) {
        return _baseMineConsumption(mines.steelMine) + _baseMineConsumption(mines.quartzMine)
            + _tritiumMineConsumption(mines.tritiumMine);
    }
}
