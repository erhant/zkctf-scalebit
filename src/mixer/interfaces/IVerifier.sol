// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IVerifier {
    function verifyProof(
        uint256[2] calldata pA,
        uint256[2][2] calldata pB,
        uint256[2] calldata pC,
        uint256 nullifier,
        uint256 root,
        uint256 recipient
    ) external view returns (bool);
}
