// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IVerifier} from "./interfaces/IVerifier.sol";
import {IMixer} from "./interfaces/IMixer.sol";
import {Verifier} from "./Verifier.sol";
import {MerkleTreeLib, MerkleTreeStruct} from "./MerkleTreeLib.sol";

contract Mixer is IMixer {
    using MerkleTreeLib for MerkleTreeStruct;

    uint256 public constant TREE_DEPTH = 20;
    uint256 public constant AMOUNT = 1 ether;
    Verifier public immutable VERIFIER;

    MerkleTreeStruct public tree;
    mapping(uint256 => bool) public commitments;
    mapping(uint256 => bool) public nullifiers;

    error InvalidAmount(uint256 amount);
    error CommitmentExists(uint256 commitment);
    error NullifierExists(uint256 nullifier);
    error InvalidRoot(uint256 root);
    error InvalidProof();
    error TransferFailed();

    event Deposit(uint256 commitment, uint256 root);
    event Withdraw(uint256 nullifier, address sender, address recipient);

    constructor() {
        VERIFIER = new Verifier();
        tree.init(TREE_DEPTH);
    }

    function deposit(uint256 commitment) external payable {
        if (msg.value != AMOUNT) revert InvalidAmount(msg.value);
        if (commitments[commitment]) revert CommitmentExists(commitment);

        uint256 root = tree.insert(commitment);
        commitments[commitment] = true;

        emit Deposit(commitment, root);
    }

    function withdraw(
        uint256[2] calldata pA,
        uint256[2][2] calldata pB,
        uint256[2] calldata pC,
        uint256 nullifier,
        uint256 root,
        address recipient
    ) external {
        if (tree.root != root) revert InvalidRoot(root);
        if (nullifiers[nullifier]) revert NullifierExists(nullifier);

        if (!verifyProof(pA, pB, pC, nullifier, root, recipient)) revert InvalidProof();

        nullifiers[nullifier] = true;

        (bool success,) = recipient.call{value: AMOUNT}("");
        if (!success) revert TransferFailed();

        emit Withdraw(nullifier, msg.sender, recipient);
    }

    function getRoot() external view returns (uint256) {
        return tree.root;
    }

    function getNumberOfLeaves() external view returns (uint256) {
        return tree.numberOfLeaves;
    }

    function verifyProof(
        uint256[2] calldata pA,
        uint256[2][2] calldata pB,
        uint256[2] calldata pC,
        uint256 nullifier,
        uint256 root,
        address recipient
    ) public view returns (bool) {
        return VERIFIER.verifyProof(pA, pB, pC, nullifier, root, uint256(uint160(recipient)));
    }
}
