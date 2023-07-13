// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "forge-std/console.sol";
// import "forge-std/Test.sol";
// import "../src/libraries/Mines.sol";

// contract CounterTest is Test {
//     Mines public mines;

//     function setUp() public {
//         mines = new Mines();
//     }

//     function testSteelMineCost() public {
//         (uint256 s0, uint256 q0) = mines.steelMineCost(0);
//         assertEq(s0, 60);
//         assertEq(q0, 15);
//         (uint256 s1, uint256 q1) = mines.steelMineCost(1);
//         assertEq(s1, 90);
//         assertEq(q1, 22);
//         (uint256 s2, uint256 q2) = mines.steelMineCost(5);
//         assertEq(s2, 455);
//         assertEq(q2, 113);
//         (uint256 s4, uint256 q4) = mines.steelMineCost(30);
//         assertEq(s4, 11505063);
//         assertEq(q4, 2876265);
//     }

//     function testQuartzMineCost() public {
//         (uint256 s0, uint256 q0) = mines.quartzMineCost(0);
//         assertEq(s0, 48);
//         assertEq(q0, 24);
//         (uint256 s1, uint256 q1) = mines.quartzMineCost(1);
//         assertEq(s1, 76);
//         assertEq(q1, 38);
//         (uint256 s2, uint256 q2) = mines.quartzMineCost(5);
//         assertEq(s2, 503);
//         assertEq(q2, 251);
//         (uint256 s4, uint256 q4) = mines.quartzMineCost(30);
//         assertEq(s4, 63802943);
//         assertEq(q4, 31901471);
//     }

//     function testTritiumMineCost() public {
//         (uint256 s0, uint256 q0) = mines.tritiumMineCost(0);
//         assertEq(s0, 225);
//         assertEq(q0, 75);
//         (uint256 s1, uint256 q1) = mines.tritiumMineCost(1);
//         assertEq(s1, 337);
//         assertEq(q1, 112);
//         (uint256 s2, uint256 q2) = mines.tritiumMineCost(5);
//         assertEq(s2, 1708);
//         assertEq(q2, 569);
//         (uint256 s4, uint256 q4) = mines.tritiumMineCost(30);
//         assertEq(s4, 43143988);
//         assertEq(q4, 14381329);
//     }

//     function testEnergyPlantMineCost() public {
//         (uint256 s0, uint256 q0) = mines.energyPlantCost(0);
//         assertEq(s0, 75);
//         assertEq(q0, 30);
//         (uint256 s1, uint256 q1) = mines.energyPlantCost(1);
//         assertEq(s1, 112);
//         assertEq(q1, 45);
//         (uint256 s2, uint256 q2) = mines.energyPlantCost(5);
//         assertEq(s2, 569);
//         assertEq(q2, 227);
//         (uint256 s4, uint256 q4) = mines.energyPlantCost(30);
//         assertEq(s4, 14381329);
//         assertEq(q4, 5752531);
//     }

//     function testSteelProduction() public {
//         uint256 s0 = mines.steelProduction(0);
//         assertEq(s0, 0);
//         uint256 s1 = mines.steelProduction(1);
//         assertEq(s1, 33);
//         uint256 s2 = mines.steelProduction(5);
//         assertEq(s2, 241);
//         uint256 s3 = mines.steelProduction(30);
//         assertEq(s3, 15704);
//     }

//     function testQuartzProduction() public {
//         uint256 s0 = mines.quartzProduction(0);
//         assertEq(s0, 0);
//         uint256 s1 = mines.quartzProduction(1);
//         assertEq(s1, 22);
//         uint256 s2 = mines.quartzProduction(5);
//         assertEq(s2, 161);
//         uint256 s3 = mines.quartzProduction(30);
//         assertEq(s3, 10469);
//     }

//     function testTritiumProduction() public {
//         uint256 s0 = mines.tritiumProduction(0);
//         assertEq(s0, 0);
//         uint256 s1 = mines.tritiumProduction(1);
//         assertEq(s1, 11);
//         uint256 s2 = mines.tritiumProduction(5);
//         assertEq(s2, 80);
//         uint256 s3 = mines.tritiumProduction(30);
//         assertEq(s3, 5234);
//     }

//     function testEnergyPlantProduction() public {
//         uint256 s0 = mines.energyPlantProduction(0);
//         assertEq(s0, 0);
//         uint256 s1 = mines.energyPlantProduction(1);
//         assertEq(s1, 22);
//         uint256 s2 = mines.energyPlantProduction(5);
//         assertEq(s2, 161);
//         uint256 s3 = mines.energyPlantProduction(30);
//         assertEq(s3, 10469);
//     }

//     function testBeseConsumption() public {
//         uint256 s0 = mines.baseMineConsumption(0);
//         assertEq(s0, 0);
//         uint256 s1 = mines.baseMineConsumption(1);
//         assertEq(s1, 11);
//         uint256 s2 = mines.baseMineConsumption(5);
//         assertEq(s2, 80);
//         uint256 s3 = mines.baseMineConsumption(30);
//         assertEq(s3, 5234);
//     }

//     function testTritiumConsumption() public {
//         uint256 s0 = mines.tritiumMineConsumption(0);
//         assertEq(s0, 0);
//         uint256 s1 = mines.tritiumMineConsumption(1);
//         assertEq(s1, 22);
//         uint256 s2 = mines.tritiumMineConsumption(5);
//         assertEq(s2, 161);
//         uint256 s3 = mines.tritiumMineConsumption(30);
//         assertEq(s3, 10469);
//     }

//     function testProductionScaler() public {
//         uint256 s0 = mines.productionScaler(22, 100, 50);
//         assertEq(s0, 22);
//         uint256 s1 = mines.productionScaler(22, 80, 100);
//         assertEq(s1, 17);
//         uint256 s2 = mines.productionScaler(22, 60, 100);
//         assertEq(s2, 13);
//         uint256 s3 = mines.productionScaler(22, 20, 100);
//         assertEq(s3, 4);
//     }
// }
