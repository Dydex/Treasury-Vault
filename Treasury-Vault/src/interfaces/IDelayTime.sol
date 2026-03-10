// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IDelayTime {
    function getExecutionDuration() external view returns (uint256);
    function getApprovalDuration() external view returns (uint256);
}