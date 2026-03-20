// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {Errors} from "../libraries/Errors.sol";

contract AccessRoles is AccessControl {
    bytes32 public constant SIGNERS_ROLE = keccak256("SIGNERS_ROLE");

    uint256 public quorum;
    uint256 public totalSigners;

    address public owner;
    address[] public signers;

    constructor(address _owner, uint8 _quorum, uint8 _totalSigners) {
        if (_quorum >= _totalSigners) {
            revert Errors.QuorumIsGreaterThanTotalSigners();
        }

        if (_owner == address(0)) {
            revert Errors.InvalidAddress();
        }

        owner = _owner;
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(SIGNERS_ROLE, owner);

        quorum = _quorum;
        totalSigners = _totalSigners;
    }

    function addCosigners(address[] calldata _cosigners) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < _cosigners.length; i++) {
            if (_cosigners.length > totalSigners) {
                revert Errors.CoSignersAreGreaterThanTotalSigners();
            } else if (_cosigners[i] == address(0)) {
                revert InvalidAddress();
            } else {
                for (uint256 j = 0; j < signers.length; j++) {
                    if (_cosigners[i] == signers[j]) {
                        revert Errors.SignerAlreadyExists();
                    }
                }
            }

            _grantRole(SIGNERS_ROLE, _cosigners[i]);
            signers.push(_cosigners[i]);
        }
    }

    function getSignerRole() external view returns (bytes32) {
        return SIGNERS_ROLE;
    }

    function getDefaultAdminRole() external view returns (bytes32) {
        return DEFAULT_ADMIN_ROLE;
    }

    function getQuorum() external view returns (uint256) {
        return quorum;
    }
}
