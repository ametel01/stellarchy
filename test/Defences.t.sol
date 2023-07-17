// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19.0;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import {Structs} from "../src/libraries/Structs.sol";
import {TestSetup} from "./Setup.t.sol";

contract DockyardTest is TestSetup {
    function test_DockyardUpgrades() public {
        address p1 = testSetUp();

        vm.startPrank(p1);
        game.dockyardUpgrade(); // dockyard 1
        game.blasterBuild(10);
        Structs.DefencesLevels memory d0 = game.getDefencesLevels(1);
        assertEq(d0.blaster, 10);

        game.dockyardUpgrade(); // dockyard 2
        game.labUpgrade(); // lab 1
        game.energyInnovationUpgrade(); // energy 1
        game.energyInnovationUpgrade(); // energy 2
        game.beamTechnologyUpgrade(); // beam 1
        game.beamTechnologyUpgrade(); // beam 2
        game.beamTechnologyUpgrade(); // beam 3
        game.beamBuild(10);
        Structs.DefencesLevels memory d1 = game.getDefencesLevels(1);
        assertEq(d1.beam, 10);

        game.dockyardUpgrade(); // dockyard 3
        game.dockyardUpgrade(); // dockyard 4
        game.dockyardUpgrade(); // dockyard 5
        game.dockyardUpgrade(); // dockyard 6
        game.energyInnovationUpgrade(); // energy 3
        game.energyInnovationUpgrade(); // energy 4
        game.energyInnovationUpgrade(); // energy 5
        game.energyInnovationUpgrade(); // energy 6
        game.labUpgrade(); // lab 2
        game.armourInnovationUpgrade(); // armour 1
        game.armourInnovationUpgrade(); // armour 2
        game.armourInnovationUpgrade(); // armour 3
        game.labUpgrade(); // lab 3
        game.labUpgrade(); // lab 4
        game.labUpgrade(); // lab 5
        game.labUpgrade(); // lab 6
        game.shieldTechUpgrade(); // shield 1
        game.astralLauncherBuild(10);
        Structs.DefencesLevels memory d2 = game.getDefencesLevels(1);
        assertEq(d2.astralLauncher, 10);

        game.dockyardUpgrade(); // dockyard 7
        game.dockyardUpgrade(); // dockyard 8
        game.beamTechnologyUpgrade(); // beam 4
        game.beamTechnologyUpgrade(); // beam 5
        game.beamTechnologyUpgrade(); // beam 6
        game.beamTechnologyUpgrade(); // beam 7
        game.beamTechnologyUpgrade(); // beam 8
        game.beamTechnologyUpgrade(); // beam 9
        game.beamTechnologyUpgrade(); // beam 10
        game.energyInnovationUpgrade(); // energy 7
        game.energyInnovationUpgrade(); // energy 8
        game.labUpgrade(); // lab 7
        game.shieldTechUpgrade(); // shield 2
        game.shieldTechUpgrade(); // shield 3
        game.shieldTechUpgrade(); // shield 4
        game.shieldTechUpgrade(); // shield 5
        game.spacetimeWarpUpgrade(); // spacetime 1
        game.spacetimeWarpUpgrade(); // spacetime 2
        game.spacetimeWarpUpgrade(); // spacetime 3
        game.spacetimeWarpUpgrade(); // spacetime 4
        game.spacetimeWarpUpgrade(); // spacetime 5
        game.plasmaEngineeringUpgrade(); // plasma 1
        game.plasmaEngineeringUpgrade(); // plasma 2
        game.plasmaEngineeringUpgrade(); // plasma 3
        game.plasmaEngineeringUpgrade(); // plasma 4
        game.plasmaEngineeringUpgrade(); // plasma 5
        game.plasmaEngineeringUpgrade(); // plasma 6
        game.plasmaEngineeringUpgrade(); // plasma 7
        game.plasmaProjectorBuild(10);
        Structs.DefencesLevels memory d3 = game.getDefencesLevels(1);
        assertEq(d3.plasmaProjector, 10);
    }
}