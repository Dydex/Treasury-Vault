// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract AccesRoles is AccesControl { 
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SIGNERS_ROLE = keccak256("SIGNERS_ROLE");

    uint public quorum;
    uint public totalSigners;

    address public owner;
    address[] public signers;

    error QuorumIsGreaterThanTotalSigners();
    error CoSignersAreGreaterThanTotalSigners();
    error SignerAlreadyExists();
    error InvalidAddress();

    constructor(address _owner, uint8 _quorum, uint8 _totalSigners) {
        if (_quorum >= _totalSigners) {
            revert QuorumIsGreaterThanTotalSigners();
        }

        if (_owner == address(0)) {
            revert InvalidAddress();
        }

        owner = _owner;
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(SIGNERS_ROLE, owner);

        quorum = _quorum;
        totalSigners = _totalSigners;
    }

    
    function addCosigners (address[] calldata _cosigners) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint i = 0; i < _cosigners.length; i++) {
            if (_cosigners.length > totalSigners) {
                revert CoSignersAreGreaterThanTotalSigners();
            } else if (_cosigners[i] == address(0)) {
                revert InvalidAddress();
            } else {
                for (uint j = 0; j < signers.length; j++) {
                    if (_cosigners[i] == signers[j]) {
                        revert SignerAlreadyExists();
                    }
                }
            }

            _grantRole(SIGNERS_ROLE, _cosigners[i]);
            signers.push(_cosigners[i]);
        }
    }

    function hasRole(bytes32 role, address account) external view returns (bool){
        return hasRole(role, account);
    };

    function getSignerRole() external view returns (bytes32) {
        return SIGNERS_ROLE;
    };

    function getDefaultAdminRole() external view returns (bytes32) {
        return DEFAULT_ADMIN_ROLE;
    };

    function getQuorum() external view returns (uint) {
        return quorum;
    }; 
}