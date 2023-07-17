// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import {Structs} from "./libraries/Structs.sol";
import {Compounds} from "./Compounds.sol";
import {Lab} from "./Lab.sol";
import {Dockyard} from "./Dockyard.sol";
import {Defences} from "./Defences.sol";
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

    receive() external payable {}

    function generatePlanet() external payable {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        require(erc721.balanceOf(msg.sender) == 0, "MAX_PLANET_PER_ADDRESS");
        require(msg.value >= PRICE, "NOT_ENOUGH_ETHER");
        erc721.mint(msg.sender, numberOfPlanets + 1);
        numberOfPlanets += 1;
        _mintInitialLiquidity(msg.sender);
    }

    function steelMineUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.ERC20s memory cost = _steelMineCost(steelMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        steelMineLevel[planetId] += 1;
    }

    function quartzMineUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.ERC20s memory cost = _quartzMineCost(quartzMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        quartzMineLevel[planetId] += 1;
    }

    function tritiumMineUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.ERC20s memory cost = _tritiumMineCost(
            tritiumMineLevel[planetId]
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        tritiumMineLevel[planetId] += 1;
    }

    function energyPlantUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.ERC20s memory cost = _energyPlantCost(
            energyPlantLevel[planetId]
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        energyPlantLevel[planetId] += 1;
    }

    function dockyardUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.ERC20s memory cost = _dockyardCost(dockyardLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        dockyardLevel[planetId] += 1;
    }

    function labUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.ERC20s memory cost = _labCost(labLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        labLevel[planetId] += 1;
    }

    function energyInnovationUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        energyInnovationRequirements(labLevel[planetId]);
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.Techs memory techs = _getTechsLevels(planetId);
        beamTechnologyRequirements(labLevel[planetId], techs);
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.Techs memory techs = _getTechsLevels(planetId);
        ionSystemsRequirements(labLevel[planetId], techs);
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.Techs memory techs = _getTechsLevels(planetId);
        plasmaEngineeringRequirements(labLevel[planetId], techs);
        Structs.ERC20s memory cost = getTechCost(
            plasmaEngineeringLevel[planetId],
            2000,
            4000,
            1000
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        plasmaEngineeringLevel[planetId] += 1;
    }

    function armsDevelopmentUpgrade() external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        armsDevelopmentRequirements(labLevel[planetId]);
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.Techs memory techs = _getTechsLevels(planetId);
        shieldTechRequirements(labLevel[planetId], techs);
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.Techs memory techs = _getTechsLevels(planetId);
        spacetimeWarpRequirements(labLevel[planetId], techs);
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.Techs memory techs = _getTechsLevels(planetId);
        combustiveDriveRequirements(labLevel[planetId], techs);
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.Techs memory techs = _getTechsLevels(planetId);
        thrustPropulsionRequirements(labLevel[planetId], techs);
        Structs.ERC20s memory cost = getTechCost(
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
        Structs.Techs memory techs = _getTechsLevels(planetId);
        warpDriveRequirements(labLevel[planetId], techs);
        Structs.ERC20s memory cost = getTechCost(
            warpDriveLevel[planetId],
            10000,
            20000,
            6000
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        warpDriveLevel[planetId] += 1;
    }

    function carrierBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.Techs memory techs = _getTechsLevels(planetId);
        carrierRequirements(dockyardLevel[planetId], techs);
        Structs.ERC20s memory cost = getShipsCost(amount, 0, 2000, 500);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        carrierAvailable[planetId] += amount;
    }

    function celestiaBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.Techs memory techs = _getTechsLevels(planetId);
        celestiaRequirements(dockyardLevel[planetId], techs);
        Structs.ERC20s memory cost = getShipsCost(amount, 0, 2000, 500);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        celestiaAvailable[planetId] += amount;
    }

    function sparrowBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        sparrowRequirements(dockyardLevel[planetId]);
        Structs.ERC20s memory cost = getShipsCost(amount, 6000, 4000, 0);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        sparrowAvailable[planetId] += amount;
    }

    function scraperBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.Techs memory techs = _getTechsLevels(planetId);
        scraperRequirements(dockyardLevel[planetId], techs);
        Structs.ERC20s memory cost = getShipsCost(amount, 10000, 6000, 2000);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        scraperAvailable[planetId] += amount;
    }

    function frigateBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.Techs memory techs = _getTechsLevels(planetId);
        frigateRequirements(dockyardLevel[planetId], techs);
        Structs.ERC20s memory cost = getShipsCost(amount, 20000, 7000, 2000);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        frigateAvailable[planetId] += amount;
    }

    function armadeBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.Techs memory techs = _getTechsLevels(planetId);
        armadeRequirements(dockyardLevel[planetId], techs);
        Structs.ERC20s memory cost = getShipsCost(amount, 45000, 15000, 0);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        armadeAvailable[planetId] += amount;
    }

    function blasterBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        blasterRequirements(dockyardLevel[planetId]);
        Structs.ERC20s memory cost = getDefencesCost(amount, 2000, 0, 0);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        blasterAvailable[planetId] += amount;
    }

    function beamBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.Techs memory techs = _getTechsLevels(planetId);
        beamRequirements(dockyardLevel[planetId], techs);
        Structs.ERC20s memory cost = getDefencesCost(amount, 6000, 2000, 0);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        beamAvailable[planetId] += amount;
    }

    function astralLauncherBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.Techs memory techs = _getTechsLevels(planetId);
        astralLauncherRequirements(dockyardLevel[planetId], techs);
        Structs.ERC20s memory cost = getDefencesCost(
            amount,
            20000,
            15000,
            2000
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        astralLauncherAvailable[planetId] += amount;
    }

    function plasmaProjectorBuild(uint amount) external {
        collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.Techs memory techs = _getTechsLevels(planetId);
        plasmaProjectorRequirements(dockyardLevel[planetId], techs);
        Structs.ERC20s memory cost = getDefencesCost(
            amount,
            50000,
            50000,
            3000
        );
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        plasmaAvailable[planetId] += amount;
    }

    function collectResources() public {
        uint256 planetId = _getTokenOwner(msg.sender);
        Structs.ERC20s memory amounts = getCollectibleResources(planetId);
        _recieveResourcesERC20(msg.sender, amounts);
        resourcesTimer[planetId] = block.timestamp;
    }

    function getTokenAddresses()
        external
        view
        returns (Structs.Tokens memory tokens)
    {
        Structs.Tokens memory _tokens;
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
    ) public view returns (Structs.Compounds memory levels) {
        return _compoundsLevels(planetId);
    }

    function getCompoundsUpgradeCost(
        uint256 planetId
    ) external view returns (Structs.CompoundsCost memory cost) {
        Structs.CompoundsCost memory _cost;
        _cost.steelMine = _steelMineCost(steelMineLevel[planetId]);
        _cost.quartzMine = _quartzMineCost(quartzMineLevel[planetId]);
        _cost.tritiumMine = _tritiumMineCost(tritiumMineLevel[planetId]);
        _cost.energyPlant = _energyPlantCost(energyPlantLevel[planetId]);
        _cost.dockyard = _dockyardCost(dockyardLevel[planetId]);
        _cost.lab = _labCost(labLevel[planetId]);
        return _cost;
    }

    function getSpendableResources(
        uint256 planetId
    ) external view returns (Structs.ERC20s memory resources) {
        Structs.Interfaces memory interfaces = _getInterfaces();
        Structs.ERC20s memory amounts;
        address account = interfaces.erc721.ownerOf(planetId);
        amounts.steel = interfaces.steel.balanceOf(account);
        amounts.quartz = interfaces.quartz.balanceOf(account);
        amounts.tritium = interfaces.tritium.balanceOf(account);
        return amounts;
    }

    function getCollectibleResources(
        uint256 planetId
    ) public view returns (Structs.ERC20s memory resources) {
        Structs.ERC20s memory _resources;
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
        Structs.Compounds memory mines = getCompoundsLevels(planetId);
        uint256 grossProduction = _energyPlantProduction(
            energyPlantLevel[planetId]
        );
        int256 energyRequired = _calculateEnergyConsumption(mines);
        return int256(grossProduction) - energyRequired;
    }

    function getShipsLevels(
        uint256 planeId
    ) external view returns (Structs.ShipsLevels memory) {
        Structs.ShipsLevels memory ships;
        ships.carrier = carrierAvailable[planeId];
        ships.celestia = celestiaAvailable[planeId];
        ships.scraper = scraperAvailable[planeId];
        ships.sparrow = sparrowAvailable[planeId];
        ships.frigate = frigateAvailable[planeId];
        ships.armade = armadeAvailable[planeId];
        return ships;
    }

    function getDefencesLevels(
        uint256 planeId
    ) external view returns (Structs.DefencesLevels memory) {
        Structs.DefencesLevels memory defences;
        defences.blaster = blasterAvailable[planeId];
        defences.beam = beamAvailable[planeId];
        defences.astralLauncher = astralLauncherAvailable[planeId];
        defences.plasmaProjector = plasmaAvailable[planeId];
        return defences;
    }

    function _initializer(
        address erc721,
        address steel,
        address quartz,
        address tritium
    ) private {
        erc721Address = erc721;
        steelAddress = steel;
        quartzAddress = quartz;
        tritiumAddress = tritium;
    }

    function _getTokenOwner(address account) private view returns (uint256) {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        return erc721.tokenOf(account);
    }

    function _getInterfaces() private view returns (Structs.Interfaces memory) {
        Structs.Interfaces memory interfaces;
        interfaces.erc721 = ISTERC721(erc721Address);
        interfaces.steel = ISTERC20(steelAddress);
        interfaces.quartz = ISTERC20(quartzAddress);
        interfaces.tritium = ISTERC20(tritiumAddress);
        return interfaces;
    }

    function _compoundsLevels(
        uint256 planetId
    ) private view returns (Structs.Compounds memory) {
        Structs.Compounds memory compounds;
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
    ) private view returns (uint256) {
        return block.timestamp - resourcesTimer[planetId];
    }

    function _mintInitialLiquidity(address caller) private {
        Structs.Interfaces memory interfaces = _getInterfaces();
        interfaces.steel.mint(caller, 500);
        interfaces.quartz.mint(caller, 300);
        interfaces.tritium.mint(caller, 100);
    }

    function _recieveResourcesERC20(
        address caller,
        Structs.ERC20s memory amounts
    ) private {
        Structs.Interfaces memory interfaces = _getInterfaces();
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
        Structs.ERC20s memory amounts
    ) private {
        Structs.Interfaces memory interfaces = _getInterfaces();
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
        Structs.ERC20s memory cost
    ) private {
        resourcesSpent[planetId] += (cost.steel + cost.quartz);
    }

    function _calculateEnergyConsumption(
        Structs.Compounds memory mines
    ) private pure returns (int256) {
        return
            int256(
                _baseMineConsumption(mines.steelMine) +
                    _baseMineConsumption(mines.quartzMine) +
                    _tritiumMineConsumption(mines.tritiumMine)
            );
    }

    function _getTechsLevels(
        uint256 planetId
    ) private view returns (Structs.Techs memory) {
        Structs.Techs memory techs;
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
