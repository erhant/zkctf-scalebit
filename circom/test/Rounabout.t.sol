// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Roundabout} from "../src/Roundabout.sol";

contract RoundaboutTest is Test {
    Roundabout public roundabout;

    function setUp() public {
        roundabout = new Roundabout();
    }

    function testSolve() public {
        uint256[2] memory pA = [
            0x11a9acc4a19662507dd75d0803ec8ed8f62171cbb4648cabfc1de3d879129149,
            0x04dabddd9cbd313b6ec7fbb75430e6e1998ccbad2e1bb3324b4395637acbbfa3
        ];
        uint256[2][2] memory pB = [
            [
                0x0b0dc2eaba2314d1f25f62233186eaf1da40a9eaec3eedb285781a995992d660,
                0x060a641e3dc458addc66164381e54fce55cbfdfd1db1d3b2f38eb524626e520c
            ],
            [
                0x27c4a3122a70e738e1340d6429c7bb50a8318214403cd6aa2441317d6803f28b,
                0x103b2c94caa6886841c39851a2b387e3dfbd9f62d15299d9d60e00e8fb152655
            ]
        ];
        uint256[2] memory pC = [
            0x04a27fa40ceb42c943feaef8418ecee6df53754dc2e7411d58e5810c9eeb3a70,
            0x2e4698f73bc567ca482a798e50bd99bc2f81c48b28c5316c8947db72db8ae697
        ];
        uint256[1] memory pubSignals = [uint256(0x00000000000000000000000000000000000000000000000000000000025d2f72)];

        roundabout.verify(pA, pB, pC, pubSignals);
        assertTrue(roundabout.isSolved(), "flag not set!");
    }
}
