// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19.0;

import "forge-std/console.sol";
import "forge-std/Test.sol";

// import {Structs} from "../src/libraries/Structs.sol";
import {TestSetup} from "./Setup.t.sol";

contract LabTest is Test, TestSetup {
    function test_Upgrade() public {
        address p1 = testSetUp();

        vm.startPrank(p1);
        game.labUpgrade(); // lab 1
        game.energyInnovationUpgrade(); // energy 1
        game.digitalSystemsUpgrade(); // digital 1
        game.beamTechnologyUpgrade(); // beam 1
        game.combustionDriveUpgrade(); // combustion 1
        game.labUpgrade(); // lab 2
        game.armourInnovationUpgrade(); // armour 1
        game.thrustPropulsionUpgrade(); // thrust 1
        game.labUpgrade(); // lab 3
        game.labUpgrade(); // lab 4
        game.armsDevelopmentUpgrade(); // arms 1
        game.beamTechnologyUpgrade(); // beam 2
        game.beamTechnologyUpgrade(); // beam 3
        game.beamTechnologyUpgrade(); // beam 4
        game.beamTechnologyUpgrade(); // beam 4
        game.energyInnovationUpgrade(); // energy 2
        game.energyInnovationUpgrade(); // energy 3
        game.energyInnovationUpgrade(); // energy 4
        game.ionSystemsUpgrade(); // ion 1
        game.energyInnovationUpgrade(); // energy 5
        game.energyInnovationUpgrade(); // energy 6
        game.labUpgrade(); // lab 5
        game.labUpgrade(); // lab 6
        game.shieldTechUpgrade(); // shield 1
        game.shieldTechUpgrade(); // shield 2
        game.shieldTechUpgrade(); // shield 3
        game.shieldTechUpgrade(); // shield 4
        game.shieldTechUpgrade(); // shield 5
        game.labUpgrade(); // lab 7
        game.spacetimeWarpUpgrade(); // st warp 1
        game.spacetimeWarpUpgrade(); // st warp 2
        game.spacetimeWarpUpgrade(); // st warp 3
        game.spacetimeWarpUpgrade(); // st warp 4
        game.spacetimeWarpUpgrade(); // st warp 5
        game.beamTechnologyUpgrade(); // beam 5
        game.beamTechnologyUpgrade(); // beam 6
        game.beamTechnologyUpgrade(); // beam 7
        game.beamTechnologyUpgrade(); // beam 9
        game.beamTechnologyUpgrade(); // beam 10
        game.energyInnovationUpgrade(); // energy 6
        game.energyInnovationUpgrade(); // energy 7
        game.energyInnovationUpgrade(); // energy 8
        game.plasmaEngineeringUpgrade(); // plasma 1
        // game.stellarPhysicsUpgrade(); // stellarphysics 1
        game.warpDriveUpgrade(); // warpdrive 1
    }

    function testFail_Upgrade() public {
        address p1 = testSetUp();
        vm.startPrank(p1);

        game.energyInnovationUpgrade();
        game.digitalSystemsUpgrade();
        game.beamTechnologyUpgrade();
        game.armourInnovationUpgrade();
        game.ionSystemsUpgrade();
        game.plasmaEngineeringUpgrade();
        game.armsDevelopmentUpgrade();
        game.shieldTechUpgrade();
        game.spacetimeWarpUpgrade();
        game.combustionDriveUpgrade();
        game.thrustPropulsionUpgrade();
        game.warpDriveUpgrade();
    }
}