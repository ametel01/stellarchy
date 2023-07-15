// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "../src/tokens/STERC721.sol";
import "../src/tokens/STERC20.sol";
import "../src/Stellarchy.sol";

contract TestSetup is Test {
    uint256 public constant ONE_DAY = 86400;
    STERC721 internal erc721;
    STERC20 internal steel;
    STERC20 internal quartz;
    STERC20 internal tritium;
    Stellarchy internal game;

    function setUp() public {
        erc721 = new STERC721();
        steel = new STERC20("Stellarchy Steel", "SST");
        quartz = new STERC20("Stellarchy Quartz", "SQZ");
        tritium = new STERC20("Stellarchy Tritium", "STT");
        game = new Stellarchy(address(erc721), address(steel), address(quartz), address(tritium));

        erc721.setMinter(address(game));
        steel.setMinter(address(game));
        quartz.setMinter(address(game));
        tritium.setMinter(address(game));
    }
}
