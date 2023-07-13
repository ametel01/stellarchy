// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "forge-std/console.sol";
// import "forge-std/Test.sol";
// import "../src/libraries/Compounds.sol";

// contract CounterTest is Test {
//     Compounds public compounds;

//     function setUp() public {
//         compounds = new Compounds();
//     }

//     function testDockyardCost() public {
//         (uint256 s1, uint256 q1, uint256 t1) = compounds.dockyardCost(0);
//         assertEq(s1, 400);
//         assertEq(q1, 200);
//         assertEq(t1, 100);
//         (uint256 s2, uint256 q2, uint256 t2) = compounds.dockyardCost(1);
//         assertEq(s2, 800);
//         assertEq(q2, 400);
//         assertEq(t2, 200);
//         (uint256 s3, uint256 q3, uint256 t3) = compounds.dockyardCost(5);
//         assertEq(s3, 12800);
//         assertEq(q3, 6400);
//         assertEq(t3, 3200);
//         (uint256 s4, uint256 q4, uint256 t4) = compounds.dockyardCost(20);
//         assertEq(s4, 419430400);
//         assertEq(q4, 209715200);
//         assertEq(t4, 104857600);
//     }

//     function testLabCost() public {
//         (uint256 s1, uint256 q1, uint256 t1) = compounds.labCost(0);
//         assertEq(s1, 200);
//         assertEq(q1, 400);
//         assertEq(t1, 200);
//         (uint256 s2, uint256 q2, uint256 t2) = compounds.labCost(1);
//         assertEq(s2, 400);
//         assertEq(q2, 800);
//         assertEq(t2, 400);
//         (uint256 s3, uint256 q3, uint256 t3) = compounds.labCost(5);
//         assertEq(s3, 6400);
//         assertEq(q3, 12800);
//         assertEq(t3, 6400);
//         (uint256 s4, uint256 q4, uint256 t4) = compounds.labCost(20);
//         assertEq(s4, 209715200);
//         assertEq(q4, 419430400);
//         assertEq(t4, 209715200);
//     }
// }
