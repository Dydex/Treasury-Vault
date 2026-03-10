// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract DelayTime {

    uint256 public approvalDuration;

    uint256 public executionDuration;

    function setExecutionDuration(uint256 _duration) external {
        executionDuration = _duration * 1 hours ;
    }

    function getExecutionDuration() external view returns (uint256) {
        return executionDuration;
    }

    function setApprovalDuration(uint256 _duration) external {
        approvalDuration = _duration * 1 hours;
    }

    function getApprovalDuration() external view returns (uint256) {
        return approvalDuration;
    }
}
