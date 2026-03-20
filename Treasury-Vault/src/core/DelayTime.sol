// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IAccessRoles} from "../interfaces/IAcessRoles.sol";
import {Errors} from "../libraries/Errors.sol";

contract DelayTime {
    IAccessRoles public accessRoles;

    uint256 public executionDuration;

    constructor(address _accessRoles) {
        accessRoles = IAccessRoles(_accessRoles);
    }

    function setExecutionDuration(uint256 _duration) external {
        if (!accessRoles.hasRole(accessRoles.getDefaultAdminRole(), msg.sender)) {
            revert Errors.NotADefaultAdmin();
        }

        executionDuration = _duration * 1 hours;
    }

    function getExecutionDuration() external view returns (uint256) {
        return executionDuration;
    }
}
