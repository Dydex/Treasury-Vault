// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IAccessRoles} from "../interfaces/IAcessRoles.sol";
import {Errors} from "../libraries/Errors.sol";

contract ClaimDistribution {
    bytes32 public merkleRoot;
    IERC20 public token;
    IAccessRoles public accessRoles;

    mapping(address => bool) public hasClaimed;

    event MerkleRootUpdated(bytes32 indexed newRoot);
    event Claimed(address indexed user, uint256 amount);

    constructor(address _token, bytes32 _merkleRoot, address _accessRoles) {
        accessRoles = IAccessRoles(_accessRoles);
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
    }

    function setMerkleRoot(bytes32 _root) external {
        if (!accessRoles.hasRole(accessRoles.getDefaultAdminRole(), msg.sender)) {
            revert Errors.NotADefaultAdmin();
        }

        merkleRoot = _root;
        emit MerkleRootUpdated(_root);
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        if (hasClaimed[msg.sender]) {
            revert Errors.AlreadyClaimed();
        }

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));

        if (!MerkleProof.verify(proof, merkleRoot, leaf)) {
            revert Errors.InvalidProof();
        }

        hasClaimed[msg.sender] = true;

        if (!token.transfer(msg.sender, amount)) {
            revert Errors.TransferFailed();
        }

        emit Claimed(msg.sender, amount);
    }
}
