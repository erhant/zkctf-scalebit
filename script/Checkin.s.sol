// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {CheckIn} from "../src/Checkin.sol";

contract Solve is Script {
    CheckIn public checkin;
    uint256 deployerPrivkey;

    function setUp() public {
        deployerPrivkey = vm.envUint("SOLVER_PRIVATE_KEY");
        checkin = CheckIn(vm.envAddress("CHECKIN_ADDR"));
    }

    function run() public {
        uint256[24] memory proof = [
            0x25e946cb1e18e53ea483735fdf73a99b559e1f70788430642473e4990bff1e86,
            0x096be957466bcedd2ca7bcac40996e58a3431e6fd923bfd94f75ce2b6dcbc5b9,
            0x030c73fc0f6bd9d2779b78d953246094873119be610db94a96f92ab89778b517,
            0x18f441734bea2a90e3f2c266669dbde685044ddf948ad5d06aeb492cf4a7584e,
            0x00f79c3ec3ba2e70b5149f70e9ad88c47d295b6a8edba8bb5761c7b8c55035b2,
            0x13bd31db4650b87712300faa33ce8e07f83f34dea40d22414aba937697c74893,
            0x24a80cc61a01526ed36df2456470de4ac5766d24fc5ab4d7239e74195587d834,
            0x06fd9c288749724bd22677fd657b8cfe21252676eb32762531910458bdb762be,
            0x24710942afd091ca80d4c490a188d7d5ae47fb09b90b024761e3dfb7b50e344f,
            0x0900d0cd1f4aff0d2b0f1d5cc16b1fcc4b95471b9c3406d6e785f428675a110d,
            0x1d2acf6b365735d8ef5b0423859c33b40e0d601dc4b0c4dbdd3731538364eb38,
            0x2a32fede0051172497c25cf9a73a6301f047791ac888813b28869fe8d8a9de23,
            0x09e5a40a6f4a35ccf539da7852a2ade9be802e25c5ca7488ac6dbecdca5ae12f,
            0x200a848a83d867d151070e6423a4dbfc0e5dc339fb20193c8e21249946f9978e,
            0x2242a88b73c0e8f9d7311b3f5b7231ae97acf0ddfb7f135f64d9b6dc7a892b0d,
            0x2b615b53b28b038eb4b25368aee932bb720403117a43c702bb51fce8244593dc,
            0x205490282ba3021a5066ac9764b38916e9af0c889f67c2cedd625ff2349a2dbb,
            0x00b6f1354037026280e2e87dee22dbb408946f93987e54f8f169a201979cbd98,
            0x123e58a2bfe7812415f3f22938971e714a2a074baa9b01c53305f37dcf00e0c7,
            0x10d4af1200cf58f4609c7878bdd296823c5ca2054ef63ec00de4015a7d23d2be,
            0x0a04ab141c1e5d1cbb87d3841e9af14b4fdf95a462964b7675b8b2c0e289efb8,
            0x17802b2a16c2a583e158740571eedae4450dda7487fd8b780fdb7d8f51da91f7,
            0x2554e6fd15d5033fd52f6199649e5c0d987cd3aac3ab9ac09472f6598574a27c,
            0x0627ba902fe48a27d0369ffe54d90638c2d8b597020d54555fc186769114104e
        ];
        uint256[1] memory pubSignals = [uint256(0x000000000000000000000000000000000000000000000000000000000000000a)];

        vm.startBroadcast(deployerPrivkey);

        checkin.verify(proof, pubSignals);
        require(checkin.isSolved(), "flag is not true.");

        vm.stopBroadcast();
    }
}
