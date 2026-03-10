// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAccessRoles {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getSignerRole() external view returns (bytes32);
    function getQuorum() external view returns (uint256);
    function getDefaultAdminRole() external view returns (bytes32);
}
