// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Structs} from "../src/libraries/Structs.sol";

import {TestSetup} from "./Setup.t.sol";

contract BaseGamesTests is TestSetup {
    function test_Generate() public {
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

    function test_Views() public {
        address p1 = vm.addr(0x1);
        deal(p1, 1 ether);

        vm.prank(p1);
        game.generatePlanet{value: 0.01 ether}();

        Structs.Tokens memory tokens = game.getTokenAddresses();
        assertEq(tokens.erc721, address(erc721));
        assertEq(tokens.steel, address(steel));
        assertEq(tokens.quartz, address(quartz));
        assertEq(tokens.tritium, address(tritium));

        assertEq(game.getNumberOfPlanets(), 1);

        Structs.Compounds memory levels = game.getCompoundsLevels(1);
        assertEq(levels.steelMine, 0);
        assertEq(levels.quartzMine, 0);
        assertEq(levels.tritiumMine, 0);
        assertEq(levels.dockyard, 0);
        assertEq(levels.lab, 0);

        Structs.CompoundsCost memory costs = game.getCompoundsUpgradeCost(1);
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

        Structs.ERC20s memory resources = game.getSpendableResources(1);
        assertEq(resources.steel, 500);
        assertEq(resources.quartz, 300);
        assertEq(resources.tritium, 100);

        vm.startPrank(p1);
        game.energyPlantUpgrade();
        game.steelMineUpgrade();
        game.quartzMineUpgrade();
        game.tritiumMineUpgrade();
        vm.warp(ONE_DAY * 10);
        // game.tritiumMineUpgrade();
        Structs.ERC20s memory collectible = game.getCollectibleResources(1);
        assertEq(collectible.steel, 7919);
        assertEq(collectible.quartz, 5279);
        assertEq(collectible.tritium, 2639);

        vm.warp(ONE_DAY * 10);
        game.collectResources();
        Structs.ERC20s memory resources_up = game.getSpendableResources(1);
        assertEq(resources_up.steel, 8011);
        assertEq(resources_up.quartz, 5435);
        assertEq(resources_up.tritium, 2739);

        Structs.TechsCost memory costs1 = game.getTechsUpgradeCosts(1);
        assertEq(costs1.energyInnovation.quartz, 800);
        assertEq(costs1.energyInnovation.tritium, 400);
        
        assertEq(costs1.digitalSystems.quartz, 400);
        assertEq(costs1.digitalSystems.tritium, 600);
        
        assertEq(costs1.beamTechnology.quartz, 800);
        assertEq(costs1.beamTechnology.tritium, 400);
        
        assertEq(costs1.ionSystems.steel, 1000);
        assertEq(costs1.ionSystems.quartz, 300);
        assertEq(costs1.ionSystems.tritium, 1000);

        assertEq(costs1.plasmaEngineering.steel, 2000);
        assertEq(costs1.plasmaEngineering.quartz, 4000);
        assertEq(costs1.plasmaEngineering.tritium, 1000);

        assertEq(costs1.spacetimeWarp.quartz, 4000);
        assertEq(costs1.spacetimeWarp.tritium, 2000);

        assertEq(costs1.combustiveDrive.steel, 400);
        assertEq(costs1.combustiveDrive.tritium, 600);

        assertEq(costs1.thrustPropulsion.steel, 2000);
        assertEq(costs1.thrustPropulsion.quartz, 4000);
        assertEq(costs1.thrustPropulsion.tritium, 600);

        assertEq(costs1.warpDrive.steel, 10000);
        assertEq(costs1.warpDrive.quartz, 2000);
        assertEq(costs1.warpDrive.tritium, 6000);

        assertEq(costs1.armourInnovation.steel, 1000);

        assertEq(costs1.armsDevelopment.steel, 800);
        assertEq(costs1.armsDevelopment.quartz, 200);

        assertEq(costs1.shieldTech.steel, 200);
        assertEq(costs1.shieldTech.quartz, 600);
        
    }
}
