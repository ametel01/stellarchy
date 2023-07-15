// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import "./Utils.t.sol";
import "../src/libraries/Compounds.sol";
import "../src/libraries/Structs.sol";

contract CompoundsTests is Test, TestSetup, Compounds {
    function testCompoundsUpgrade() public {
        address p1 = vm.addr(0x1);
        deal(p1, 1 ether);
        vm.prank(p1);
        game.generatePlanet{value: 0.01 ether}();

        vm.startPrank(p1);
        game.energyPlantUpgrade();
        game.steelMineUpgrade();
        game.quartzMineUpgrade();
        game.tritiumMineUpgrade();
        console.logInt(game.getEnergyAvailable(1));
        vm.warp(ONE_DAY * 10);
        game.energyPlantUpgrade();
        game.energyPlantUpgrade();
        game.steelMineUpgrade();
        game.quartzMineUpgrade();
        game.tritiumMineUpgrade();
        game.dockyardUpgrade();
        game.labUpgrade();
        ERC20s memory resources = game.getSpendableResources(1);
        assertEq(resources.steel, 6628);
        assertEq(resources.quartz, 4551);
        assertEq(resources.tritium, 2439);
    }

    function testSteelMineCost() public {
        assertEq(steelMineCost(0).steel, 60);
        assertEq(steelMineCost(0).quartz, 15);
        assertEq(steelMineCost(1).steel, 90);
        assertEq(steelMineCost(1).quartz, 22);
        assertEq(steelMineCost(5).steel, 455);
        assertEq(steelMineCost(5).quartz, 113);
        assertEq(steelMineCost(30).steel, 11505063);
        assertEq(steelMineCost(30).quartz, 2876265);
    }

    function testQuartzMineCost() public {
        assertEq(quartzMineCost(0).steel, 48);
        assertEq(quartzMineCost(0).quartz, 24);
        assertEq(quartzMineCost(1).steel, 76);
        assertEq(quartzMineCost(1).quartz, 38);
        assertEq(quartzMineCost(5).steel, 503);
        assertEq(quartzMineCost(5).quartz, 251);
        assertEq(quartzMineCost(30).steel, 63802943);
        assertEq(quartzMineCost(30).quartz, 31901471);
    }

    function testTritiumMineCost() public {
        assertEq(tritiumMineCost(0).steel, 225);
        assertEq(tritiumMineCost(0).quartz, 75);
        assertEq(tritiumMineCost(1).steel, 337);
        assertEq(tritiumMineCost(1).quartz, 112);
        assertEq(tritiumMineCost(5).steel, 1708);
        assertEq(tritiumMineCost(5).quartz, 569);
        assertEq(tritiumMineCost(30).steel, 43143988);
        assertEq(tritiumMineCost(30).quartz, 14381329);
    }

    function testEnergyPlantMineCost() public {
        assertEq(energyPlantCost(0).steel, 75);
        assertEq(energyPlantCost(0).quartz, 30);
        assertEq(energyPlantCost(1).steel, 112);
        assertEq(energyPlantCost(1).quartz, 45);
        assertEq(energyPlantCost(5).steel, 569);
        assertEq(energyPlantCost(5).quartz, 227);
        assertEq(energyPlantCost(30).steel, 14381329);
        assertEq(energyPlantCost(30).quartz, 5752531);
    }

    function testSteelProduction() public {
        uint256 s0 = steelProduction(0);
        assertEq(s0, 0);
        uint256 s1 = steelProduction(1);
        assertEq(s1, 33);
        uint256 s2 = steelProduction(5);
        assertEq(s2, 241);
        uint256 s3 = steelProduction(30);
        assertEq(s3, 15704);
    }

    function testQuartzProduction() public {
        uint256 s0 = quartzProduction(0);
        assertEq(s0, 0);
        uint256 s1 = quartzProduction(1);
        assertEq(s1, 22);
        uint256 s2 = quartzProduction(5);
        assertEq(s2, 161);
        uint256 s3 = quartzProduction(30);
        assertEq(s3, 10469);
    }

    function testTritiumProduction() public {
        uint256 s0 = tritiumProduction(0);
        assertEq(s0, 0);
        uint256 s1 = tritiumProduction(1);
        assertEq(s1, 11);
        uint256 s2 = tritiumProduction(5);
        assertEq(s2, 80);
        uint256 s3 = tritiumProduction(30);
        assertEq(s3, 5234);
    }

    function testEnergyPlantProduction() public {
        uint256 s0 = energyPlantProduction(0);
        assertEq(s0, 0);
        uint256 s1 = energyPlantProduction(1);
        assertEq(s1, 22);
        uint256 s2 = energyPlantProduction(5);
        assertEq(s2, 161);
        uint256 s3 = energyPlantProduction(30);
        assertEq(s3, 10469);
    }

    function testBeseConsumption() public {
        uint256 s0 = baseMineConsumption(0);
        assertEq(s0, 0);
        uint256 s1 = baseMineConsumption(1);
        assertEq(s1, 11);
        uint256 s2 = baseMineConsumption(5);
        assertEq(s2, 80);
        uint256 s3 = baseMineConsumption(30);
        assertEq(s3, 5234);
    }

    function testTritiumConsumption() public {
        uint256 s0 = tritiumMineConsumption(0);
        assertEq(s0, 0);
        uint256 s1 = tritiumMineConsumption(1);
        assertEq(s1, 22);
        uint256 s2 = tritiumMineConsumption(5);
        assertEq(s2, 161);
        uint256 s3 = tritiumMineConsumption(30);
        assertEq(s3, 10469);
    }

    function testProductionScaler() public {
        uint256 s0 = productionScaler(22, 100, 50);
        assertEq(s0, 22);
        uint256 s1 = productionScaler(22, 80, 100);
        assertEq(s1, 17);
        uint256 s2 = productionScaler(22, 60, 100);
        assertEq(s2, 13);
        uint256 s3 = productionScaler(22, 20, 100);
        assertEq(s3, 4);
    }
}
