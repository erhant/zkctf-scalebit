// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IPoseidonT3 {
    function hash(uint256[2] memory) external pure returns (uint256);
}
