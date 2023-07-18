// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import {STERC721} from "../src/tokens/STERC721.sol";
import {STERC20} from "../src/tokens/STERC20.sol";
import {Stellarchy} from "../src/Stellarchy.sol";
import {Structs} from "../src/libraries/Structs.sol";

contract TestSetup is Test {
    uint256 public constant ONE_DAY = 86400;
    STERC721 internal erc721;
    STERC20 internal steel;
    STERC20 internal quartz;
    STERC20 internal tritium;
    Stellarchy internal game;

    function setUp() public {
        erc721 = new STERC721("ipfs://QmUA4rfEYVtSKtjgckPFEaZHir5bhFdWZMRcqMQp5wFpvu");
        steel = new STERC20("Stellarchy Steel", "SST");
        quartz = new STERC20("Stellarchy Quartz", "SQZ");
        tritium = new STERC20("Stellarchy Tritium", "STT");
        game = new Stellarchy(
            address(erc721),
            address(steel),
            address(quartz),
            address(tritium)
        );

        erc721.setMinter(address(game));
        steel.setMinter(address(game));
        quartz.setMinter(address(game));
        tritium.setMinter(address(game));
    }

    function testSetUp() public returns (address) {
        address p1 = vm.addr(0x1);
        deal(p1, 1 ether);
        address p2 = vm.addr(0x2);
        deal(p2, 1 ether);
        vm.startPrank(p1);
        game.generatePlanet{value: 0.01 ether}();
        game.energyPlantUpgrade();
        game.steelMineUpgrade();
        game.quartzMineUpgrade();
        game.energyPlantUpgrade();
        game.steelMineUpgrade();
        vm.warp(ONE_DAY);
        game.steelMineUpgrade();
        game.quartzMineUpgrade();
        game.energyPlantUpgrade();
        game.tritiumMineUpgrade();
        game.tritiumMineUpgrade();
        game.energyPlantUpgrade();
        vm.warp(ONE_DAY*100000000);
        game.collectResources();
        // ERC20s memory resources = game.getSpendableResources(1); 
        // console.log(resources.steel, resources.quartz, resources.tritium);
        return p1;

    }
}
