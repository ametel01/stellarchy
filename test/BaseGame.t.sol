// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/libraries/Structs.sol";

import "./Utils.t.sol";

contract BaseGamesTests is TestSetup, Structs {
    function testGenerate() public {
        address p1 = vm.addr(0x1);
        deal(p1, 1 ether);
        address p2 = vm.addr(0x2);
        deal(p2, 1 ether);

        vm.prank(p1);
        game.generatePlanet{value: 0.01 ether}();

        assertEq(erc721.balanceOf(p1), 1);
        assertEq(steel.balanceOf(p1), 500);
        assertEq(quartz.balanceOf(p1), 300);
        assertEq(tritium.balanceOf(p1), 100);

        vm.startPrank(p2);
        game.generatePlanet{value: 0.01 ether}();

        assertEq(erc721.balanceOf(p2), 1);
        assertEq(steel.balanceOf(p2), 500);
        assertEq(quartz.balanceOf(p2), 300);
        assertEq(tritium.balanceOf(p2), 100);

        assertEq(game.getNumberOfPlanets(), 2);
    }

    function testViews() public {
        address p1 = vm.addr(0x1);
        deal(p1, 1 ether);

        vm.prank(p1);
        game.generatePlanet{value: 0.01 ether}();

        Tokens memory tokens = game.getTokenAddresses();
        assertEq(tokens.erc721, address(erc721));
        assertEq(tokens.steel, address(steel));
        assertEq(tokens.quartz, address(quartz));
        assertEq(tokens.tritium, address(tritium));

        assertEq(game.getNumberOfPlanets(), 1);

        Compounds memory levels = game.getCompoundsLevels(1);
        assertEq(levels.steelMine, 0);
        assertEq(levels.quartzMine, 0);
        assertEq(levels.tritiumMine, 0);
        assertEq(levels.dockyard, 0);
        assertEq(levels.lab, 0);

        CompoundsCost memory costs = game.getCompoundsUpgradeCost(1);
        assertEq(costs.steelMine.steel, 60);
        assertEq(costs.steelMine.quartz, 15);

        assertEq(costs.quartzMine.steel, 48);
        assertEq(costs.quartzMine.quartz, 24);

        assertEq(costs.tritiumMine.steel, 225);
        assertEq(costs.tritiumMine.quartz, 75);

        assertEq(costs.energyPlant.steel, 75);
        assertEq(costs.energyPlant.quartz, 30);

        assertEq(costs.dockyard.steel, 400);
        assertEq(costs.dockyard.quartz, 200);
        assertEq(costs.dockyard.tritium, 100);

        assertEq(costs.lab.steel, 200);
        assertEq(costs.lab.quartz, 400);
        assertEq(costs.lab.tritium, 200);

        ERC20s memory resources = game.getSpendableResources(1);
        assertEq(resources.steel, 500);
        assertEq(resources.quartz, 300);
        assertEq(resources.tritium, 100);

        vm.startPrank(p1);
        game.steelMineUpgrade();
        game.quartzMineUpgrade();
        game.tritiumMineUpgrade();
        vm.warp(3600);
        ERC20s memory collectible = game.getCollectibleResources(1);
        assertEq(collectible.steel, 32);
        assertEq(collectible.quartz, 21);
        assertEq(collectible.tritium, 10);
    }
}
