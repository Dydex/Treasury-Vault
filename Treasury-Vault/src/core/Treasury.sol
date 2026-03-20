// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "../interfaces/IERC20.sol";
import {Errors} from "../libraries/Errors.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Treasury is ReentrancyGuard {
    IERC20 public token;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    uint256 public totalBalance;

    mapping(address => uint256) public balances;

    event DepositSuccessFul(address indexed sender, uint256 amount);

    function depositToken(uint256 _amount) external {
        if (_amount == 0) {
            revert Errors.InvalidAmount();
        }

        if (token.balanceOf(msg.sender) < _amount) {
            revert Errors.InsufficientFunds();
        }

        token.transferFrom(msg.sender, address(this), _amount);

        balances[msg.sender] += _amount;

        totalBalance += _amount;

        emit DepositSuccessFul(msg.sender, _amount);
    }

    function withdrawToken(uint256 _amount) external {
        if (_amount == 0) {
            revert InvalidAmount();
        }

        if (balances[msg.sender] < _amount) {
            revert InsufficientFunds();
        }

        token.transfer(msg.sender, _amount);

        balances[msg.sender] -= _amount;

        totalBalance -= _amount;
    }

    function getUserBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function withdrawFundsForProposal(address _to, uint256 _amount) external nonReentrant {
        if (msg.sender != address(this)) {
            revert Errors.OnlyTreasuryCanCallThisFunction();
        }

        if (_to == address(0)) {
            revert Errors.InvalidAddress();
        }

        if (_amount == 0) {
            revert Errors.InvalidAmount();
        }

        if (totalBalance < _amount) {
            revert Errors.InsufficientFunds();
        }

        token.transfer(_to, _amount);

        totalBalance -= _amount;
    }
}
