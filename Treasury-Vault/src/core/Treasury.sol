// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "../interfaces/IERC20.sol";

contract Treasury {

    IERC20 public token;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);

    } 

uint public totalBalance;

mapping(address => uint) public balances;

error InvalidAmount();
error InsufficientFunds();
error OnlyTreasuryCanCallThisFunction();

event DepositSuccessFul(address indexed sender, uint value);

function depositToken(uint _amount) external {
    if (_amount == 0) {
        revert InvalidAmount();
    }

    if (token.balanceOf(msg.sender) < _amount) {
        revert InsufficientFunds();
    }

    token.transferFrom(msg.sender, address(this), _amount);

    balances[msg.sender] += _amount;

    totalBalance += _amount;

    emit DepositSuccessFul(msg.sender, _value);
}

function withdrawToken(uint _amount) external {
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

function getUserBalance() external view returns (uint) {
    return balances[msg.sender];
}

function withdrawFundsForProposal(address _to, uint _amount) external  {

    if ( msg.sender != address(this)) {
        revert OnlyTreasuryCanCallThisFunction();
    }

    if( _to == address(0)) {
        revert InvalidAddress();
    }

    if (_amount == 0) {
        revert InvalidAmount();
    }

    if (totalBalance < _amount) {
        revert InsufficientFunds();
    }

    token.transfer(_to, _amount);

    totalBalance -= _amount;

}

function emergencyWithdrawAll()

}
