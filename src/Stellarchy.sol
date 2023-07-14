// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./libraries/Structs.sol";
import "./libraries/Compounds.sol";
import "./libraries/Lab.sol";
import "./libraries/Dockyard.sol";
import "./libraries/Defences.sol";
import "./tokens/STERC20.sol";

contract Stellarchy is Compounds, Lab, Dockyard, Defences {
    uint256 public constant _price = 0.01 ether;

    address payable public owner;

    uint256 numberOfPlanets;

    mapping(uint256 => uint256) resourcesSpent;

    address erc721Address;

    address steelAddress;

    address quartzAddress;

    address tritiumAddress;

    mapping(uint256 => uint256) resourcesTimer;

    constructor(address erc721, address steel, address quartz, address tritium, address _owner) {
        _initializer(erc721, steel, quartz, tritium, _owner);
    }

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

    function getPlanetPoints(uint256 planetId) external view returns (uint256 points) {
        return resourcesSpent[planetId] / 1000;
    }

    function getCompoundsLevels(uint256 planetId) external view returns (Compounds memory levels) {
        return _compoundsLevels(planetId);
    }

    function getCompoundsUpgradeCost(uint256 planetId) external view returns (CompoundsCost memory cost) {
        CompoundsCost memory _cost;
        _cost.steelMine = steelMineCost(steelMineLevel[planetId]);
        _cost.quartzMine = quartzMineCost(quartzMineLevel[planetId]);
        _cost.tritiumMine = tritiumMineCost(tritiumMineLevel[planetId]);
        _cost.energyPlant = energyPlantCost(energyPlantLevel[planetId]);
        _cost.dockyard = dockyardCost(dockyardLevel[planetId]);
        _cost.lab = labCost(labLevel[planetId]);
        return _cost;
    }

    function getSpendableResources(uint256 planetId) external view returns (ERC20s memory resurces) {
        Interfaces memory interfaces = _getInterfaces();
        ERC20s memory amounts;
        address account = _getTokenOwner(planetId);
        amounts.steel = interfaces.steel.balanceOf(account);
        amounts.quartz = interfaces.quartz.balanceOf(account);
        amounts.tritium = interfaces.tritium.balanceOf(account);
        return amounts;
    }

    function getCollectibleResources(uint256 planetId) external view returns (ERC20s memory resources) {
        ERC20s memory _resources;
        uint256 timeElapsed = _timeSinceLastCollection(planetId);
        _resources.steel = steelProduction(steelMineLevel[planetId] * timeElapsed / 3600);
        _resources.quartz = quartzProduction(quartzMineLevel[planetId] * timeElapsed / 3600);
        _resources.tritium = tritiumProduction(tritiumMineLevel[planetId] * timeElapsed / 3600);
        return _resources;
    }

    // External Functions
    function generatePlanet() external payable {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        require(erc721.balanceOf(msg.sender) == 0, "MAX_PLANET_PER_ADDRESS");
        erc721.mint(msg.sender, numberOfPlanets + 1);
        _mintInitialLiquidity(msg.sender);
    }

    function collectResources() public {
        uint256 planetId = _getTokenOwner(msg.sender);
        ERC20s memory amounts = getCollectibleResources(planetId);
        _payResourcesERC20(msg.sender, amounts);
        resourcesTimer[planetId] = time.now;
    }

    // Internal Functions
    function _initializer(address erc721, address steel, address quartz, address tritium, address _owner)
        internal
        virtual
    {
        erc721Address = erc721;
        steelAddress = steel;
        quartzAddress = quartz;
        tritiumAddress = tritium;
        owner = payable(_owner);
    }

    function _getTokenOwner(uint256 tokenId) internal view returns (address) {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        return erc721.tokenOf(tokenId);
    }

    function _getInterfaces() internal view returns (Interfaces memory) {
        Interfaces memory interfaces;
        interfaces.erc721 = ISTERC721(erc721Address);
        interfaces.steel = ISTERC20(steelAddress);
        interfaces.quartz = ISTERC20(quartzAddress);
        interfaces.tritium = ISTERC20(tritiumAddress);
        return interfaces;
    }

    function _compoundsLevels(uint256 planetId) internal view returns (Compounds memory) {
        Compounds memory compounds;
        compounds.steelMine = steelMineLevel[planetId];
        compounds.quartzMine = quartzMineLevel[planetId];
        compounds.tritiumMine = tritiumMineLevel[planetId];
        compounds.energyPlant = energyPlantLevel[planetId];
        compounds.dockyard = dockyardLevel[planetId];
        compounds.lab = labLevel[planetId];
        return compounds;
    }

    function _timeSinceLastCollection(uint256 planetId) internal view returns (uint256) {
        return block.timestamp - resourcesTimer[planetId];
    }

    function _mintInitialLiquidity(address caller) internal {
        Interfaces memory interfaces = _getInterfaces();
        interfaces.steel.mint(caller, 500);
        interfaces.quartz.mint(caller, 300);
        interfaces.tritium.mint(caller, 100);
    }

    function _recieveResourcesERC20(address caller, ERC20s memory amounts) internal {
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

    function _payResourcesERC20(address caller, ERC20s memory amounts) internal {
        Interfaces memory interfaces = _getInterfaces();
        if (amounts.steel > 0) {
            interfaces.steel.burn(caller, amounts.steel);
        }
        if (amounts.quartz > 0) {
            interfaces.quartz.burn(caller, amounts.quartz);
        }
        if (amounts.tritium > 0) {
            interfaces.tritium.burn(caller, amounts.tritium);
        }
    }
}
