// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Checkin} from "../src/Checkin.sol";

contract Solve is Script {
    Checkin public checkin;
    uint256 deployerPrivkey;

    function setUp() public {
        deployerPrivkey = vm.envUint("SOLVER_PRIVATE_KEY");
        checkin = Checkin(vm.envAddress("CHECKIN_ADDR"));
    }

    function run() public {
        // 1. npx circomkit compile checkin
        // 2. npx circomkit prove checkin default
        // 2. npx circomkit calldata checkin default
        uint256[2] memory pA = [
            0x29746be93e9b90b110137e927f104955e9774b58045aa905eb345a3b62d8fdb8,
            0x23734e1d2ea285ea11a13512b1012af5b6b9c1d92c4d660610c32c1d06dbe177
        ];
        uint256[2][2] memory pB = [
            [
                0x15240ae5e9b73b960d0df17d2efe5df98a10ee477886af7b9b2115351cc870f2,
                0x083ff2a99fa75cb923bdf4969a10f46825fae0cfbdba84188467b50bf4350f4d
            ],
            [
                0x1484e113994fd51952711463b50988a0c7d25e4c8be6c3338f650e829867d9d2,
                0x22d19836b87eada679ab51d8295b5d5e007721f994691d387e368e3c31bad95e
            ]
        ];
        uint256[2] memory pC = [
            0x1f9a989178159015a06ba6af4e8f6c95c4e464644a569fdd27f15250bb687047,
            0x07ba8e205a3193ccd5421703f1e47fff873c7446794fb2a8253a15b36d652f27
        ];
        uint256[1] memory pubSignals = [uint256(0x0000000000000000000000000000000000000000000000000000000000000001)];
        vm.startBroadcast(deployerPrivkey);

        checkin.verify(pA, pB, pC, pubSignals);
        require(checkin.isSolved(), "flag is not true.");

        vm.stopBroadcast();
    }
}
