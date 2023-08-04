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

/// @title Stellarchy
/// @author [ametel01]
/// @notice This is the main contract for the Stellarchy game.
/// @dev This contract inherits Ownable, Compounds, Lab, Dockyard, and Defences.
contract Stellarchy is Ownable, Compounds, Lab, Dockyard, Defences {
    /// @dev A constant for E18, representing 10^18 which is commonly used for decimals in ERC20 tokens.
    uint256 private constant E18 = 10 ** 18;

    /// @dev The constant price for something in the contract, specified in Ether.
    /// Note that solidity has a built-in keyword for Ether, so '0.01 ether' will be converted to Wei by the compiler.
    uint256 public constant PRICE = 0.01 ether;

    /// @dev The address that will receive payments or other transactions. It is payable, so it can receive Ether transactions.
    address payable private _receiver;

    /// @dev A variable to store the total number of planets in the game or contract.
    uint256 private numberOfPlanets;

    /// @dev A mapping to track the resources spent for each planet. The key is the planet ID and the value is the resources spent.
    mapping(uint256 => uint256) private resourcesSpent;

    /// @dev The contract address of the ERC721 token, which could represent ownership of planets.
    address private erc721Address;

    /// @dev Contract address of the "steel" resource token. Likely an ERC20 token.
    address private steelAddress;

    /// @dev Contract address of the "quartz" resource token. Likely an ERC20 token.
    address private quartzAddress;

    /// @dev Contract address of the "tritium" resource token. Likely an ERC20 token.
    address private tritiumAddress;

    /// @dev A mapping to track the resource timers for each planet. The key is the planet ID and the value is the timer (likely in seconds since Unix Epoch).
    mapping(uint256 => uint256) private _resourcesTimer;

    /// @dev Emitted when total resources are spent on a planet.
    /// @param planetId The id of the planet on which resources have been spent.
    /// @param amount The total amount of resources spent.
    event TotalResourcesSpent(uint256 planetId, uint256 amount);

    /// @dev Emitted when resources are spent on fleet on a planet.
    /// @param planetId The id of the planet on which resources have been spent for the fleet.
    /// @param amount The amount of resources spent for the fleet.
    event FleetSpent(uint256 planetId, uint256 amount);

    /// @dev Emitted when resources are spent on technology on a planet.
    /// @param planetId The id of the planet on which resources have been spent for the technology.
    /// @param amount The amount of resources spent for the technology.
    event TechSpent(uint256 planetId, uint256 amount);

    /**
     * @notice Constructs and initializes the contract, setting the initial receiver to the contract creator.
     *
     * @dev The constructor sets the contract creator (msg.sender) as the initial `_receiver`.
     *      The `_receiver` is a state variable where, incoming funds are directed.
     */
    constructor() {
        _receiver = payable(msg.sender);
    }

    /**
     * @notice A default function that gets called when ether is sent to the contract without any data.
     *
     * @dev This function is only called on plain Ether transfers, i.e. when there is no data in the transaction.
     * If you want to handle `msg.data` along with an Ether payment, you need to define a fallback function.
     *
     * @dev This function does not perform any operations and simply allows the contract to receive Ether.
     *
     * @dev This function is marked as `external` which means it's only callable from the outside. It is also `payable`
     * so that it can receive Ether.
     */
    receive() external payable {}

    /**
     * @notice Initializes the addresses for the ERC721 contract and the ERC20 contracts for steel, quartz, and tritium.
     *
     * @dev This is an internal function, meaning it can only be called from within the contract itself or contracts deriving from it.
     *
     * @dev This function can only be called by the contract owner.
     *
     * @dev The addresses provided must be the addresses of contracts that adhere to the ERC721 and ERC20 standards.
     *
     * @param erc721 The address of the deployed ERC721 contract.
     * @param steel The address of the deployed ERC20 contract for steel.
     * @param quartz The address of the deployed ERC20 contract for quartz.
     * @param tritium The address of the deployed ERC20 contract for tritium.
     */
    function _initializer(address erc721, address steel, address quartz, address tritium) external onlyOwner {
        erc721Address = erc721;
        steelAddress = steel;
        quartzAddress = quartz;
        tritiumAddress = tritium;
    }

    /**
     * @notice Allows for the withdrawal of all Ether stored in this contract to a receiver address.
     *
     * @dev This function can only be called by the owner of the contract.
     * It retrieves the balance of the contract and attempts to send it to the receiver.
     * If the transfer fails, it will revert the transaction.
     *
     * @dev The receiver's address should be payable, as it is going to receive ethers.
     * This function doesn't handle the case where the contract's balance is 0.
     *
     * @dev Uses low-level call function to transfer ethers, which provides a safety check for reentrancy attack.
     *
     * @dev Throws if the sending of Ether fails.
     */
    function withdraw() public {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success,) = _receiver.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    /**
     * @notice This function allows users to generate a new planet by sending a specified amount of Ether.
     * The new planet is represented as an NFT token and is minted to the address of the sender.
     * A resources timer is also initiated for the new planet.
     *
     * @dev This function can only be called by external accounts and requires that the sender does not already own a planet (an ERC721 token).
     * It also requires that the value sent with the function call is equal to or greater than a predefined price.
     *
     * @dev The function makes use of an ERC721 token, the address of which is stored in a state variable `erc721Address`.
     *
     * @dev The function also triggers `_mintInitialLiquidity` function after successful minting of the planet NFT.
     *
     * @dev Throws if the sender already owns a planet or if the value sent with the function call is less than the predefined price.
     *
     * @dev Emits a Transfer event, as part of the ERC721 token minting process.
     */
    function generatePlanet() external payable {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        require(erc721.balanceOf(msg.sender) == 0, "MAX_PLANET_PER_ADDRESS");
        require(msg.value >= PRICE, "NOT_ENOUGH_ETHER");
        erc721.mint(msg.sender, numberOfPlanets + 1);
        numberOfPlanets += 1;
        _resourcesTimer[numberOfPlanets + 1] = block.timestamp;
        _mintInitialLiquidity(msg.sender);
    }

    /// @notice This function allows a user to collect resources.
    function collectResources() external {
        _collectResources();
    }

    /**
     * @notice Performs a compound upgrade for the token owned by the message sender.
     * This function first collects any pending resources, then it calculates the costs of the upgrade
     * based on the current laboratory level of the sender's planet. It charges the sender's resources
     * and updates the compound level accordingly.
     *
     * @dev This function emits the TotalResourcesSpent event upon successful upgrade.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the sender doesn't have enough resources for the upgrade.
     */
    function steelMineUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _steelMineCost(steelMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        steelMineLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a compound upgrade for the token owned by the message sender.
     * This function first collects any pending resources, then it calculates the costs of the upgrade
     * based on the current laboratory level of the sender's planet. It charges the sender's resources
     * and updates the compound level accordingly.
     *
     * @dev This function emits the TotalResourcesSpent event upon successful upgrade.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the sender doesn't have enough resources for the upgrade.
     */
    function quartzMineUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _quartzMineCost(quartzMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        quartzMineLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a compound upgrade for the token owned by the message sender.
     * This function first collects any pending resources, then it calculates the costs of the upgrade
     * based on the current laboratory level of the sender's planet. It charges the sender's resources
     * and updates the compound level accordingly.
     *
     * @dev This function emits the TotalResourcesSpent event upon successful upgrade.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the sender doesn't have enough resources for the upgrade.
     */
    function tritiumMineUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _tritiumMineCost(tritiumMineLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        tritiumMineLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a compound upgrade for the token owned by the message sender.
     * This function first collects any pending resources, then it calculates the costs of the upgrade
     * based on the current laboratory level of the sender's planet. It charges the sender's resources
     * and updates the compound level accordingly.
     *
     * @dev This function emits the TotalResourcesSpent event upon successful upgrade.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the sender doesn't have enough resources for the upgrade.
     */
    function energyPlantUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _energyPlantCost(energyPlantLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        energyPlantLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a compound upgrade for the token owned by the message sender.
     * This function first collects any pending resources, then it calculates the costs of the upgrade
     * based on the current laboratory level of the sender's planet. It charges the sender's resources
     * and updates the compound level accordingly.
     *
     * @dev This function emits the TotalResourcesSpent event upon successful upgrade.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the sender doesn't have enough resources for the upgrade.
     */
    function dockyardUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _dockyardCost(dockyardLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        dockyardLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a compound upgrade for the token owned by the message sender.
     * This function first collects any pending resources, then it calculates the costs of the upgrade
     * based on the current laboratory level of the sender's planet. It charges the sender's resources
     * and updates the compound level accordingly.
     *
     * @dev This function emits the TotalResourcesSpent event upon successful upgrade.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the sender doesn't have enough resources for the upgrade.
     */
    function labUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory cost = _labCost(labLevel[planetId]);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        labLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function energyInnovationUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        energyInnovationRequirements(labLevel[planetId]);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(energyInnovationLevel[planetId], techsCosts.energyInnovation);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        energyInnovationLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function digitalSystemsUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        digitalSystemsRequirements(labLevel[planetId]);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(digitalSystemsLevel[planetId], techsCosts.digitalSystems);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        digitalSystemsLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function beamTechnologyUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        beamTechnologyRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(beamTechnologyLevel[planetId], techsCosts.beamTechnology);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        beamTechnologyLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function ionSystemsUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        ionSystemsRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(ionSystemsLevel[planetId], techsCosts.ionSystems);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        ionSystemsLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function plasmaEngineeringUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        plasmaEngineeringRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(plasmaEngineeringLevel[planetId], techsCosts.plasmaEngineering);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        plasmaEngineeringLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function spacetimeWarpUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        spacetimeWarpRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(spacetimeWarpLevel[planetId], techsCosts.spacetimeWarp);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        spacetimeWarpLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function combustionDriveUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        combustiveDriveRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(combustiveDriveLevel[planetId], techsCosts.combustiveDrive);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        combustiveDriveLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function thrustPropulsionUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        thrustPropulsionRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(thrustPropulsionLevel[planetId], techsCosts.thrustPropulsion);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        thrustPropulsionLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function warpDriveUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        warpDriveRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(warpDriveLevel[planetId], techsCosts.warpDrive);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        warpDriveLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function armourInnovationUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        armourRequirements(labLevel[planetId]);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(armourInnovationLevel[planetId], techsCosts.armourInnovation);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        armourInnovationLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */
    function weaponsDevelopmentUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        armsDevelopmentRequirements(labLevel[planetId]);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(armsDevelopmentLevel[planetId], techsCosts.armsDevelopment);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        armsDevelopmentLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }
    /**
     * @notice Performs a tech upgrade for the token owned by the message sender.
     * It first collects any pending resources, then it checks the tech requirements for the upgrade.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding shield tech level for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and TechSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the upgrade requirements are not met or if the sender doesn't have enough resources.
     */

    function shieldTechUpgrade() external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        shieldTechRequirements(labLevel[planetId], techs);
        S.TechsCost memory techsCosts = getTechsUpgradeCosts();
        S.ERC20s memory cost = techUpgradeCost(shieldTechLevel[planetId], techsCosts.shieldTech);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        shieldTechLevel[planetId] += 1;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit TechSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Handles the construction of new fleet units for the planet owned by the message sender.
     * The process starts with resource collection, checking the current technology levels of the planet,
     * and confirming the dockyard and tech requirements. Then it calculates the cost of the units,
     * charges the sender's resources, and updates the corresponding armade available for the sender's planet.
     *
     * @param amount The number of fleet units to be built.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     */
    function carrierBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        carrierRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.carrier);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        carrierAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Handles the construction of new fleet units for the planet owned by the message sender.
     * The process starts with resource collection, checking the current technology levels of the planet,
     * and confirming the dockyard and tech requirements. Then it calculates the cost of the units,
     * charges the sender's resources, and updates the corresponding armade available for the sender's planet.
     *
     * @param amount The number of fleet units to be built.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     */
    function celestiaBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        celestiaRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.celestia);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        celestiaAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Handles the construction of new fleet units for the planet owned by the message sender.
     * The process starts with resource collection, checking the current technology levels of the planet,
     * and confirming the dockyard and tech requirements. Then it calculates the cost of the units,
     * charges the sender's resources, and updates the corresponding armade available for the sender's planet.
     *
     * @param amount The number of fleet units to be built.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     */
    function sparrowBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        sparrowRequirements(dockyardLevel[planetId]);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.sparrow);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        sparrowAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Handles the construction of new fleet units for the planet owned by the message sender.
     * The process starts with resource collection, checking the current technology levels of the planet,
     * and confirming the dockyard and tech requirements. Then it calculates the cost of the units,
     * charges the sender's resources, and updates the corresponding armade available for the sender's planet.
     *
     * @param amount The number of fleet units to be built.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     */
    function scraperBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        scraperRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.scraper);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        scraperAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Handles the construction of new fleet units for the planet owned by the message sender.
     * The process starts with resource collection, checking the current technology levels of the planet,
     * and confirming the dockyard and tech requirements. Then it calculates the cost of the units,
     * charges the sender's resources, and updates the corresponding armade available for the sender's planet.
     *
     * @param amount The number of fleet units to be built.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     */
    function frigateBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        frigateRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.frigate);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        frigateAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Handles the construction of new fleet units for the planet owned by the message sender.
     * The process starts with resource collection, checking the current technology levels of the planet,
     * and confirming the dockyard and tech requirements. Then it calculates the cost of the units,
     * charges the sender's resources, and updates the corresponding armade available for the sender's planet.
     *
     * @param amount The number of fleet units to be built.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     */
    function armadeBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        armadeRequirements(dockyardLevel[planetId], techs);
        S.ShipsCost memory unitsCost = _shipsUnitCost();
        S.ERC20s memory cost = shipsCost(amount, unitsCost.carrier);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        armadeAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Builds a specified amount of defence unit for the token owned by the message sender.
     * It first collects any pending resources, then it checks the requirements for the Plasma Projector construction.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding Plasma Projector count for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     *
     * @param amount The number of defence units to construct.
     */
    function blasterBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        blasterRequirements(dockyardLevel[planetId]);
        S.DefencesCost memory unitsCost = _defencesUnitCost();
        S.ERC20s memory cost = defencesCost(amount, unitsCost.blaster);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        blasterAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Builds a specified amount of defence unit for the token owned by the message sender.
     * It first collects any pending resources, then it checks the requirements for the Plasma Projector construction.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding Plasma Projector count for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     *
     * @param amount The number of defence units to construct.
     */
    function beamBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        beamRequirements(dockyardLevel[planetId], techs);
        S.DefencesCost memory unitsCost = _defencesUnitCost();
        S.ERC20s memory cost = defencesCost(amount, unitsCost.beam);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        beamAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Builds a specified amount of defence unit for the token owned by the message sender.
     * It first collects any pending resources, then it checks the requirements for the Plasma Projector construction.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding Plasma Projector count for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     *
     * @param amount The number of defence units to construct.
     */
    function astralLauncherBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        astralLauncherRequirements(dockyardLevel[planetId], techs);
        S.DefencesCost memory unitsCost = _defencesUnitCost();
        S.ERC20s memory cost = defencesCost(amount, unitsCost.astralLauncher);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        astralLauncherAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Builds a specified amount of defence unit for the token owned by the message sender.
     * It first collects any pending resources, then it checks the requirements for the Plasma Projector construction.
     * If requirements are met, it calculates the costs, charges the user's resources and updates
     * the corresponding Plasma Projector count for the sender's planet.
     *
     * @dev This function emits the TotalResourcesSpent and FleetSpent events upon completion.
     *
     * @dev This function can only be called by the external owner of the token.
     *
     * @dev Throws if the construction requirements are not met or if the sender doesn't have enough resources.
     *
     * @param amount The number of defence units to construct.
     */
    function plasmaProjectorBuild(uint32 amount) external {
        _collectResources();
        uint256 planetId = _getTokenOwner(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        plasmaProjectorRequirements(dockyardLevel[planetId], techs);
        S.DefencesCost memory unitsCost = _defencesUnitCost();
        S.ERC20s memory cost = defencesCost(amount, unitsCost.plasmaProjector);
        _payResourcesERC20(msg.sender, cost);
        _updateResourcesSpent(planetId, cost);
        plasmaAvailable[planetId] += amount;
        emit TotalResourcesSpent(planetId, cost.steel + cost.quartz);
        emit FleetSpent(planetId, cost.steel + cost.quartz);
    }

    /**
     * @notice Collects the pending resources for the planet owned by the message sender.
     *
     * @dev This function is a private function that is used to collect resources for a planet owned by the message sender.
     * It retrieves the amounts of resources that are ready to be collected and then delivers these resources to the sender.
     * It also updates the resources collection timestamp for the planet.
     *
     * @dev This function can only be called internally by other functions in the contract.
     *
     * @dev Throws if the sender is not a valid owner of a planet token.
     */
    function _collectResources() private {
        uint256 planetId = _getTokenOwner(msg.sender);
        S.ERC20s memory amounts = getCollectibleResources(planetId);
        _recieveResourcesERC20(msg.sender, amounts);
        _resourcesTimer[planetId] = block.timestamp;
    }

    /**
     * @notice Retrieves the current prize pool amount.
     *
     * @dev This function returns half of the contract's current ether balance.
     * This is based on the assumption that 50% of the contract's balance is dedicated to the prize pool.
     * As this function doesn't alter state, it's marked as a view function.
     *
     * @return The current value of the prize pool as half of the contract's ether balance.
     */
    function getPrizePoll() external view returns (uint256) {
        return address(this).balance / 2;
    }

    /**
     * @notice Retrieves the addresses of all associated tokens in the system.
     *
     * @dev This function returns the current addresses for the ERC721 token and the other
     * ERC20 tokens, namely steel, quartz, and tritium.
     *
     * @return tokens - A structure containing all four token addresses:
     *     erc721: The address of the ERC721 token.
     *     steel: The address of the steel token.
     *     quartz: The address of the quartz token.
     *     tritium: The address of the tritium token.
     */
    function getTokenAddresses() external view returns (S.Tokens memory tokens) {
        S.Tokens memory _tokens;
        _tokens.erc721 = erc721Address;
        _tokens.steel = steelAddress;
        _tokens.quartz = quartzAddress;
        _tokens.tritium = tritiumAddress;
        return _tokens;
    }

    /**
     * @notice Get the total number of planets in the system.
     *
     * @dev This is a view function and it doesn't alter the state of the blockchain.
     *
     * @return nPlanets The total number of planets.
     */
    function getNumberOfPlanets() external view returns (uint256 nPlanets) {
        return numberOfPlanets;
    }

    /**
     * @notice Retrieves the total points of a specific planet.
     *
     * @dev The points are calculated as the amount of resources spent by the planet divided by 1000.
     *
     * @param planetId The ID of the planet to get points for.
     *
     * @return points The calculated points of the planet.
     *
     * This function is `view`, it doesn't modify state and can be called freely without spending gas (except for the transaction itself)
     */
    function getPlanetPoints(uint256 planetId) external view returns (uint256 points) {
        return resourcesSpent[planetId] / 1000;
    }

    /**
     * @notice Returns the spendable resources (steel, quartz, and tritium) of the specified planet.
     *
     * @dev Each of the resources is divided by E18 to convert from Wei format to Ether format.
     *
     * @param planetId The identifier of the planet for which the resources are being queried.
     *
     * @return amounts The struct containing the amounts of steel, quartz, and tritium the owner of the planet has.
     *
     * @dev This function can only be called externally and is view-only, i.e., it does not alter the state.
     */
    function getSpendableResources(uint256 planetId) external view returns (S.ERC20s memory) {
        S.Interfaces memory interfaces = _getInterfaces();
        address planetOwner = interfaces.erc721.ownerOf(planetId);
        S.ERC20s memory amounts;
        amounts.steel = (interfaces.steel.balanceOf(planetOwner) / E18);
        amounts.quartz = (interfaces.quartz.balanceOf(planetOwner) / E18);
        amounts.tritium = (interfaces.tritium.balanceOf(planetOwner) / E18);
        return amounts;
    }

    /**
     * @notice Calculates and returns the collectible resources for a given planet, based on the levels of each resource production
     * facility (steel, quartz, tritium) and the time elapsed since the last collection.
     *
     * @param planetId The ID of the planet for which to calculate the collectible resources.
     *
     * @return _resources A structure containing the amount of each resource (steel, quartz, tritium) that can be collected.
     *
     * @dev The production of each resource is calculated independently, based on the level of the corresponding production facility.
     *
     * @dev Time elapsed is calculated as the difference between the current time and the last collection time, in hours.
     *
     * @dev This function is a `view`, meaning it will not modify the state.
     */
    function getCollectibleResources(uint256 planetId) public view returns (S.ERC20s memory) {
        S.ERC20s memory _resources;
        uint256 timeElapsed = _timeSinceLastCollection(planetId);
        _resources.steel = _steelProduction(steelMineLevel[planetId]) * timeElapsed / 3600;
        _resources.quartz = _quartzProduction(quartzMineLevel[planetId]) * timeElapsed / 3600;
        _resources.tritium = _tritiumProduction(tritiumMineLevel[planetId]) * timeElapsed / 3600;
        return _resources;
    }

    /**
     * @notice Calculate and return the available energy for a specific planet.
     *
     * @dev This function takes a planet ID and calculates the gross energy production
     * from both the planet's energy plant and available celestia. Then it subtracts the energy
     * consumed by the planet's mines to calculate the net energy available.
     *
     * @dev This function uses a view as it does not alter the state.
     *
     * @param planetId The unique identifier for the planet.
     *
     * @return The net energy available on the given planet.
     *
     * @dev The returned value is in the int256 data type and could be negative if energy consumption exceeds production.
     */
    function getEnergyAvailable(uint256 planetId) external view returns (int256) {
        S.Compounds memory mines = getCompoundsLevels(planetId);
        int256 grossProduction = int256(_energyPlantProduction(energyPlantLevel[planetId]));
        int256 celestiaProduction = int256(celestiaAvailable[planetId] * 15);
        int256 energyRequired = int256(_calculateEnergyConsumption(mines));
        return grossProduction + celestiaProduction - energyRequired;
    }

    /**
     * @notice Returns the levels of various compound structures for a given planet.
     *
     * @dev This function is read-only and does not modify the state.
     *
     * @param planetId The ID of the planet for which to retrieve the compound levels.
     *
     * @return levels The compound levels on the specified planet, including steel mine,
     * quartz mine, tritium mine, energy plant, dockyard, and lab.
     */
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

    /**
     * @notice Calculates and returns the upgrade costs for all the compounds of a specified planet.
     *
     * @dev It calculates the cost of upgrading each type of compound: steel mine, quartz mine, tritium mine,
     * energy plant, dockyard, and lab for a given planet.
     *
     * @param planetId The ID of the planet for which to calculate the compound upgrade costs.
     *
     * @return _cost Returns a structured data with the costs to upgrade each compound for the given planet.
     */
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

    /**
     * @notice Retrieves the current levels of all technology for a given planet.
     *
     * @dev This is a read-only function that does not modify the state.
     *
     * @param planetId The ID of the planet for which the technology levels should be retrieved.
     *
     * @return techs An S.Techs struct containing the current levels of the following technologies for the specified planet:
     * - energyInnovation
     * - digitalSystems
     * - beamTechnology
     * - armourInnovation
     * - ionSystems
     * - plasmaEngineering
     * - armsDevelopment
     * - shieldTech
     * - spacetimeWarp
     * - combustiveDrive
     * - thrustPropulsion
     * - warpDrive
     */
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

    /**
     * @notice Calculates and returns the cost of upgrading the technologies for the token owned by the message sender.
     * The function first gets the interfaces and token of the message sender, then it retrieves the tech levels of the
     * sender's planet. Lastly, it computes the cost based on the tech levels.
     *
     * @dev This function uses a view to access the state, it does not modify the contract's state.
     *
     * @return A `S.TechsCost` struct containing the calculated costs for upgrading technologies.
     */
    function getTechsUpgradeCosts() public view returns (S.TechsCost memory) {
        S.Interfaces memory interfaces = _getInterfaces();
        uint256 planetId = interfaces.erc721.tokenOf(msg.sender);
        S.Techs memory techs = getTechsLevels(planetId);
        return _techsCost(techs);
    }

    /**
     * @notice Retrieves the levels of different types of ships available for a specified planet.
     *
     * @param planetId The ID of the planet for which ship levels are to be fetched.
     *
     * @dev This function can be called by any external account.
     *
     * @return ships An `S.ShipsLevels` struct containing the levels of each type of ship available for the specified planet.
     */
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

    /**
     * @notice Fetches the cost of each ship type in the game.
     *
     * @dev This is a pure function, meaning it doesn't alter the contract's state.
     *
     * @return A struct of type S.ShipsCost that contains the cost for each type of ship.
     */
    function getShipsCost() external pure returns (S.ShipsCost memory) {
        return _shipsUnitCost();
    }

    /**
     * @notice Returns the defense levels of the specified planet.
     *
     * @dev This function returns an S.DefencesLevels struct with the levels of different defense technologies:
     * blaster, beam, astral launcher, and plasma projector.
     *
     * @param planetId The ID of the planet whose defense levels are to be retrieved.
     * @return defences An S.DefencesLevels struct containing the levels of each type of defense.
     *
     * @dev This is a view function and does not modify the state.
     */
    function getDefencesLevels(uint256 planetId) external view returns (S.DefencesLevels memory) {
        S.DefencesLevels memory defences;
        defences.blaster = blasterAvailable[planetId];
        defences.beam = beamAvailable[planetId];
        defences.astralLauncher = astralLauncherAvailable[planetId];
        defences.plasmaProjector = plasmaAvailable[planetId];
        return defences;
    }

    /**
     * @notice Returns the cost of the defences for the caller's unit.
     *
     * @dev This function is a pure function, which means it doesn't read or modify the state. It simply calculates and
     * returns the defences cost based on the `_defencesUnitCost` function.
     *
     * @return A `DefencesCost` struct that represents the cost of defences. The structure and units of this cost
     * are dependent on how your `DefencesCost` struct is defined in your `S` contract.
     */
    function getDefencesCost() external pure returns (S.DefencesCost memory) {
        return _defencesUnitCost();
    }

    /**
     * @notice Fetches the token ID associated with an account from a specified ERC721 contract.
     *
     * @dev This function uses the interface of an ISTERC721 token and calls the `tokenOf` function
     * on it to get the token ID of a specific address.
     *
     * @dev This function is a view, meaning it doesn't modify the state.
     *
     * @param account The address of the account for which the token ID is desired.
     *
     * @return The ID of the token owned by the account.
     */
    function _getTokenOwner(address account) private view returns (uint256) {
        ISTERC721 erc721 = ISTERC721(erc721Address);
        return erc721.tokenOf(account);
    }

    /**
     * @notice This is a private view function that retrieves the interface instances for
     * the ERC721 token, and the steel, quartz, and tritium ERC20 tokens.
     *
     * @dev The token addresses must be already set before calling this function.
     *
     * @return interfaces An `S.Interfaces` struct containing the initialized interfaces.
     */
    function _getInterfaces() private view returns (S.Interfaces memory) {
        S.Interfaces memory interfaces;
        interfaces.erc721 = ISTERC721(erc721Address);
        interfaces.steel = ISTERC20(steelAddress);
        interfaces.quartz = ISTERC20(quartzAddress);
        interfaces.tritium = ISTERC20(tritiumAddress);
        return interfaces;
    }

    /**
     * @dev Calculates the time that has passed since the last resource collection for a given planet.
     *
     * @param planetId The unique identifier of the planet for which to calculate the time since last resource collection.
     *
     * @return The number of seconds elapsed since the last collection.
     *
     * @dev This is a private view function, which means it doesn't modify the state and is only accessible from within this contract.
     */
    function _timeSinceLastCollection(uint256 planetId) private view returns (uint256) {
        return block.timestamp - _resourcesTimer[planetId];
    }

    /**
     * @notice Mints initial amounts of resources (steel, quartz, and tritium) to a specified address.
     *
     * @dev This function can only be called internally.
     *
     * @param caller The address to which the initial resources will be minted.
     *
     * @dev This function mints 500 units of steel, 300 units of quartz, and 100 units of tritium to the caller.
     *
     * @dev Note that the E18 constant is used for converting these amounts to their corresponding
     * representations in wei, given that Ethereum's native currency (and many ERC20 tokens) have 18 decimal places.
     */
    function _mintInitialLiquidity(address caller) private {
        S.Interfaces memory interfaces = _getInterfaces();
        interfaces.steel.mint(caller, 500 * E18);
        interfaces.quartz.mint(caller, 300 * E18);
        interfaces.tritium.mint(caller, 100 * E18);
    }

    /**
     * @notice This is a private function that mints the specified amounts of steel, quartz, and tritium
     * resources to the caller's account. The amounts are scaled by 10^18 (E18) before minting.
     *
     * @dev The function retrieves the relevant interfaces to access the mint function of each resource contract.
     *
     * @param caller The address of the account where the resources will be minted.
     * @param amounts A structure that holds the amounts of steel, quartz, and tritium to be minted.
     *
     * @dev This function should only be used in trusted, internal contexts where the caller is known to be authenticated.
     * If the amounts are nonzero, the function calls the mint function of the respective contract.
     */
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

    /**
     * @notice Deducts the specified amounts of ERC20 tokens (steel, quartz, tritium) from the caller's balance.
     *
     * @dev This is a private function and can only be called from within this contract.
     *
     * @param caller The address of the account from which the resources are to be deducted.
     * @param amounts The amount of each resource (steel, quartz, tritium) to be deducted.
     *
     * @dev Throws if the caller does not have enough of the specified resource.
     */
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

    /**
     * @dev Updates the total resources spent by a specific planet.
     * This is a private function and can only be called inside this contract.
     *
     * @param planetId The ID of the planet for which to update resources spent.
     * @param cost The cost structure, containing the amounts of steel and quartz spent.
     *
     * @notice The resources spent for a planet are stored as the sum of the steel and quartz costs.
     *
     * @dev The function modifies the `resourcesSpent` state variable,
     * adding the sum of `cost.steel` and `cost.quartz` to the current value.
     */
    function _updateResourcesSpent(uint256 planetId, S.ERC20s memory cost) private {
        resourcesSpent[planetId] += (cost.steel + cost.quartz);
    }

    /**
     * @notice Calculates the total energy consumption for all the mines owned by a player.
     *
     * @dev This is a pure function and does not modify any state. It uses other internal functions
     * to calculate the energy consumption of each mine individually.
     *
     * @param mines a structure of type S.Compounds that holds information about the mines owned by a player.
     *
     * @return the total energy consumption by all the mines in the provided S.Compounds structure.
     */
    function _calculateEnergyConsumption(S.Compounds memory mines) private pure returns (uint256) {
        return _baseMineConsumption(mines.steelMine) + _baseMineConsumption(mines.quartzMine)
            + _tritiumMineConsumption(mines.tritiumMine);
    }
}
