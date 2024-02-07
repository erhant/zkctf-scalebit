// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IVerifier} from "./IVerifier.sol";

interface IMixer {
    function commitments(uint256) external view returns (bool);

    function nullifiers(uint256) external view returns (bool);

    function deposit(uint256 commitment) external payable;

    function withdraw(
        uint256[2] calldata pA,
        uint256[2][2] calldata pB,
        uint256[2] calldata pC,
        uint256 nullifier,
        uint256 root,
        address recipient
    ) external;

    function getRoot() external view returns (uint256);

    function getNumberOfLeaves() external view returns (uint256);

    function verifyProof(
        uint256[2] calldata pA,
        uint256[2][2] calldata pB,
        uint256[2] calldata pC,
        uint256 nullifier,
        uint256 root,
        address recipient
    ) external view returns (bool);
}
