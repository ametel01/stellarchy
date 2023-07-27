// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import {Compounds} from "../src/Compounds.sol";
import {Structs} from "../src/libraries/Structs.sol";
import {TestSetup} from "./Setup.t.sol";

contract CompoundsTest is TestSetup, Compounds {
    uint256 constant E18 = 10 ** 18;

    function test_CompoundsUpgrades() public {
        address p1 = vm.addr(0x1);
        deal(p1, 1 ether);
        vm.prank(p1);
        game.generatePlanet{value: 0.01 ether}();

        vm.startPrank(p1);
        game.energyPlantUpgrade();
        game.steelMineUpgrade();
        game.quartzMineUpgrade();
        game.tritiumMineUpgrade();
        vm.warp(ONE_DAY * 10);
        game.energyPlantUpgrade();
        game.energyPlantUpgrade();
        game.steelMineUpgrade();
        game.quartzMineUpgrade();
        game.tritiumMineUpgrade();
        game.dockyardUpgrade();
        game.labUpgrade();
        game.getEnergyAvailable(1);

        Structs.ERC20s memory resources = game.getSpendableResources(1);
        assertEq(resources.steel, 6628);
        assertEq(resources.quartz, 4551);
        assertEq(resources.tritium, 2439);
        uint256 points = game.getPlanetPoints(1);
        assertEq(points, 2);
    }

    function testCollectResources() public {
        address p1 = vm.addr(0x1);
        deal(p1, 1 ether);
        vm.startPrank(p1);
        game.generatePlanet{value: 0.01 ether}();

        vm.startPrank(p1);
        game.energyPlantUpgrade();
        game.steelMineUpgrade();
        game.quartzMineUpgrade();
        game.energyPlantUpgrade();
        // game.tritiumMineUpgrade();
        int256 energy = game.getEnergyAvailable(1);
        console.logInt(energy);
        vm.warp(ONE_DAY);
        Structs.ERC20s memory collect = game.getCollectibleResources(1);
        assertEq(collect.steel, 791);
        assertEq(collect.quartz, 527);
        assertEq(collect.tritium, 0);
        game.collectResources();
        Structs.ERC20s memory spendable = game.getSpendableResources(1);
        assertEq(spendable.steel, 996);
        assertEq(spendable.quartz, 713);
        assertEq(spendable.tritium, 100);
    }

    function testSteelMineCost() public {
        assertEq(_steelMineCost(0).steel, 60);
        assertEq(_steelMineCost(0).quartz, 15);
        assertEq(_steelMineCost(1).steel, 90);
        assertEq(_steelMineCost(1).quartz, 22);
        assertEq(_steelMineCost(5).steel, 455);
        assertEq(_steelMineCost(5).quartz, 113);
        assertEq(_steelMineCost(30).steel, 11505063);
        assertEq(_steelMineCost(30).quartz, 2876265);
    }

    function testQuartzMineCost() public {
        assertEq(_quartzMineCost(0).steel, 48);
        assertEq(_quartzMineCost(0).quartz, 24);
        assertEq(_quartzMineCost(1).steel, 76);
        assertEq(_quartzMineCost(1).quartz, 38);
        assertEq(_quartzMineCost(5).steel, 503);
        assertEq(_quartzMineCost(5).quartz, 251);
        assertEq(_quartzMineCost(30).steel, 63802943);
        assertEq(_quartzMineCost(30).quartz, 31901471);
    }

    function testTritiumMineCost() public {
        assertEq(_tritiumMineCost(0).steel, 225);
        assertEq(_tritiumMineCost(0).quartz, 75);
        assertEq(_tritiumMineCost(1).steel, 337);
        assertEq(_tritiumMineCost(1).quartz, 112);
        assertEq(_tritiumMineCost(5).steel, 1708);
        assertEq(_tritiumMineCost(5).quartz, 569);
        assertEq(_tritiumMineCost(30).steel, 43143988);
        assertEq(_tritiumMineCost(30).quartz, 14381329);
    }

    function testEnergyPlantMineCost() public {
        assertEq(_energyPlantCost(0).steel, 75);
        assertEq(_energyPlantCost(0).quartz, 30);
        assertEq(_energyPlantCost(1).steel, 112);
        assertEq(_energyPlantCost(1).quartz, 45);
        assertEq(_energyPlantCost(5).steel, 569);
        assertEq(_energyPlantCost(5).quartz, 227);
        assertEq(_energyPlantCost(30).steel, 14381329);
        assertEq(_energyPlantCost(30).quartz, 5752531);
    }

    function testSteelProduction() public {
        uint256 s0 = _steelProduction(0);
        assertEq(s0, 10);
        uint256 s1 = _steelProduction(1);
        assertEq(s1, 33);
        uint256 s2 = _steelProduction(5);
        assertEq(s2, 241);
        uint256 s3 = _steelProduction(30);
        assertEq(s3, 15704);
    }

    function testQuartzProduction() public {
        uint256 s0 = _quartzProduction(0);
        assertEq(s0, 10);
        uint256 s1 = _quartzProduction(1);
        assertEq(s1, 22);
        uint256 s2 = _quartzProduction(5);
        assertEq(s2, 161);
        uint256 s3 = _quartzProduction(30);
        assertEq(s3, 10469);
    }

    function testTritiumProduction() public {
        uint256 s0 = _tritiumProduction(0);
        assertEq(s0, 0);
        uint256 s1 = _tritiumProduction(1);
        assertEq(s1, 11);
        uint256 s2 = _tritiumProduction(5);
        assertEq(s2, 80);
        uint256 s3 = _tritiumProduction(30);
        assertEq(s3, 5234);
    }

    function testEnergyPlantProduction() public {
        uint256 s0 = _energyPlantProduction(0);
        assertEq(s0, 0);
        uint256 s1 = _energyPlantProduction(1);
        assertEq(s1, 22);
        uint256 s2 = _energyPlantProduction(5);
        assertEq(s2, 161);
        uint256 s3 = _energyPlantProduction(30);
        assertEq(s3, 10469);
    }

    function testBeseConsumption() public {
        uint256 s0 = _baseMineConsumption(0);
        assertEq(s0, 0);
        uint256 s1 = _baseMineConsumption(1);
        assertEq(s1, 11);
        uint256 s2 = _baseMineConsumption(5);
        assertEq(s2, 80);
        uint256 s3 = _baseMineConsumption(30);
        assertEq(s3, 5234);
    }

    function testTritiumConsumption() public {
        uint256 s0 = _tritiumMineConsumption(0);
        assertEq(s0, 0);
        uint256 s1 = _tritiumMineConsumption(1);
        assertEq(s1, 22);
        uint256 s2 = _tritiumMineConsumption(5);
        assertEq(s2, 161);
        uint256 s3 = _tritiumMineConsumption(30);
        assertEq(s3, 10469);
    }

    function testProductionScaler() public {
        uint256 s0 = _productionScaler(22, 100, 50);
        assertEq(s0, 22);
        uint256 s1 = _productionScaler(22, 80, 100);
        assertEq(s1, 17);
        uint256 s2 = _productionScaler(22, 60, 100);
        assertEq(s2, 13);
        uint256 s3 = _productionScaler(22, 20, 100);
        assertEq(s3, 4);
    }

    function testDockyardCost() public {
        Structs.ERC20s memory cost = _dockyardCost(0);
        assertEq(cost.steel, 400);
        assertEq(cost.quartz, 200);
        assertEq(cost.tritium, 100);
        Structs.ERC20s memory cost1 = _dockyardCost(1);
        assertEq(cost1.steel, 800);
        assertEq(cost1.quartz, 400);
        assertEq(cost1.tritium, 200);
        Structs.ERC20s memory cost2 = _dockyardCost(5);
        assertEq(cost2.steel, 12800);
        assertEq(cost2.quartz, 6400);
        assertEq(cost2.tritium, 3200);
        Structs.ERC20s memory cost3 = _dockyardCost(20);
        assertEq(cost3.steel, 419430400);
        assertEq(cost3.quartz, 209715200);
        assertEq(cost3.tritium, 104857600);
    }

    function testLabCost() public {
        Structs.ERC20s memory cost1 = _labCost(0);
        assertEq(cost1.steel, 200);
        assertEq(cost1.quartz, 400);
        assertEq(cost1.tritium, 200);
        Structs.ERC20s memory cost2 = _labCost(1);
        assertEq(cost2.steel, 400);
        assertEq(cost2.quartz, 800);
        assertEq(cost2.tritium, 400);
        Structs.ERC20s memory cost3 = _labCost(5);
        assertEq(cost3.steel, 6400);
        assertEq(cost3.quartz, 12800);
        assertEq(cost3.tritium, 6400);
        Structs.ERC20s memory cost4 = _labCost(20);
        assertEq(cost4.steel, 209715200);
        assertEq(cost4.quartz, 419430400);
        assertEq(cost4.tritium, 209715200);
    }
}
