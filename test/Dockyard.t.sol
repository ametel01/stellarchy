// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19 .0;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import {Structs} from "../src/libraries/Structs.sol";
import {TestSetup} from "./Setup.t.sol";

contract DockyardTest is TestSetup {
    uint256 constant E18 = 10 ** 18;

    function test_DockyardUpgrades() public {
        address p1 = testSetUp();

        vm.startPrank(p1);
        game.dockyardUpgrade(); // dockyard 1
        game.labUpgrade(); // lab 1
        game.energyInnovationUpgrade(); // energy 1
        game.combustionDriveUpgrade(); // combustion 1
        game.celestiaBuild(10);
        Structs.ShipsLevels memory s0 = game.getShipsLevels(1);
        assertEq(s0.celestia, 10);

        game.dockyardUpgrade(); // dockyard 2
        game.combustionDriveUpgrade(); // combustion 2
        game.carrierBuild(10);
        Structs.ShipsLevels memory s1 = game.getShipsLevels(1);
        assertEq(s1.carrier, 10);

        game.dockyardUpgrade(); // dockyard 3
        game.dockyardUpgrade(); // dockyard 4
        game.sparrowBuild(10);
        Structs.ShipsLevels memory s2 = game.getShipsLevels(1);
        assertEq(s2.sparrow, 10);

        game.combustionDriveUpgrade(); // combustion 3
        game.combustionDriveUpgrade(); // combustion 4
        game.combustionDriveUpgrade(); // combustion 5
        game.combustionDriveUpgrade(); // combustion 6
        game.labUpgrade(); // lab 2
        game.labUpgrade(); // lab 3
        game.labUpgrade(); // lab 4
        game.labUpgrade(); // lab 5
        game.labUpgrade(); // lab 6
        game.energyInnovationUpgrade(); // energy 2
        game.energyInnovationUpgrade(); // energy 3
        game.energyInnovationUpgrade(); // energy 4
        game.energyInnovationUpgrade(); // energy 5
        game.energyInnovationUpgrade(); // energy 6
        game.shieldTechUpgrade(); // shield 1
        game.shieldTechUpgrade(); // shield 2
        game.scraperBuild(10);
        Structs.ShipsLevels memory s3 = game.getShipsLevels(1);
        assertEq(s3.scraper, 10);

        game.dockyardUpgrade(); // dockyard 5
        game.beamTechnologyUpgrade(); // beam 1
        game.beamTechnologyUpgrade(); // beam 2
        game.beamTechnologyUpgrade(); // beam 3
        game.beamTechnologyUpgrade(); // beam 4
        game.beamTechnologyUpgrade(); // beam 5
        game.ionSystemsUpgrade(); // ion 1
        game.ionSystemsUpgrade(); // ion 2
        game.thrustPropulsionUpgrade(); // thrust 1
        game.thrustPropulsionUpgrade(); // thrust 2
        game.thrustPropulsionUpgrade(); // thrust 3
        game.thrustPropulsionUpgrade(); // thrust 4
        game.frigateBuild(10);
        Structs.ShipsLevels memory s4 = game.getShipsLevels(1);
        assertEq(s4.frigate, 10);

        game.dockyardUpgrade(); // dockyard 6
        game.dockyardUpgrade(); // dockyard 7
        game.labUpgrade(); // lab 7
        game.shieldTechUpgrade(); // shield 3
        game.shieldTechUpgrade(); // shield 4
        game.shieldTechUpgrade(); // shield 5
        game.spacetimeWarpUpgrade(); // spacetime 1
        game.spacetimeWarpUpgrade(); // spacetime 2
        game.spacetimeWarpUpgrade(); // spacetime 3
        game.warpDriveUpgrade(); // warp 1
        game.warpDriveUpgrade(); // warp 2
        game.warpDriveUpgrade(); // warp 3
        game.warpDriveUpgrade(); // warp 4
        game.armadeBuild(10);
        Structs.ShipsLevels memory s5 = game.getShipsLevels(1);
        assertEq(s5.armade, 10);
    }
}
