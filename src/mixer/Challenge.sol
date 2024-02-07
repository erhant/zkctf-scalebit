// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IMixer} from "./interfaces/IMixer.sol";

contract Challenge {
    IMixer public immutable MIXER;

    constructor(IMixer mixer) {
        MIXER = mixer;
    }

    function isSolved() external view returns (bool) {
        return address(MIXER).balance == 0;
    }
}
