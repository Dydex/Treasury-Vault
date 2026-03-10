// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IAccessRoles} from "../interfaces/IAcessRoles.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IDelayTime} from "../interfaces/IDelayTime.sol";

contract TransactionProposal {
    IAccessRoles public accessRoles;

    IERC20 public token;

    constructor(address _accessRoles, address _tokenAddress) {
        accessRoles = IAccessRoles(_accessRoles);
        token = IERC20(_tokenAddress);
        delayTime = IDelayTime(_delayTime);
    }

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        uint256 signatureCount;
        bool created;
        uint256 submissionTime;
        uint256 executionTime;
        uint256 approvalTime;
    }

    uint256 quorum = accessRoles.getQuorum();
    uint256 public transactionCount;
    uint public proposalFee;

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmedSignatories;

    event TransactionExecuted(uint256 indexed transactionId, address indexed to, uint256 value);

    error InvalidAddress();
    error QuorumReached();
    error TransactionAlreadyExists();
    error NotASigner();

    function setProposalFee(uint _fee) external {
        if (!accessRoles.hasRole(accessRoles.getDefaultAdminRole(), msg.sender)) {
            revert NotASigner();
        }
        proposalFee = _fee;
    }

    function createTransaction(address _to, uint256 _value) external payable {
        if (proposalFee != msg.value) 
            revert InvalidProposalFee();

        // check if they have paid for this tnx by id,bool 


        uint256 transactionId = transactionCount++;

        if (_to == address(0)) {
            revert InvalidAddress();
        }

        if (transactions[transactionId].created) {
            revert TransactionAlreadyExists();
        } // check this Id stuff later

        transactions[transactionId] = Transaction({
            to: _to,
            value: _value,
            executed: false,
            signatureCount: 0,
            created: true,
            creationTime: block.timestamp,
            executionTime: 0
            approvalTime: block.timestamp + delayTime.getApprovalDuration();
        });
        confirmedSignatories[transactionId][msg.sender] = true;
    }

    

    function confirmTransaction(uint256 _transactionId) external {
        require(accessRoles.hasRole(accessRoles.getSignerRole(), msg.sender), "Not A Signers");

        Transaction storage transaction = transactions[_transactionId];

        if (transactions[_transactionId].signatureCount == quorum) {
            revert QuorumReached();
        }

        if (!transaction.created) {
            revert TransactionAlreadyExists();
        }

         if (transaction.executed) {
            revert TransactionAlreadyExecuted();
        }

         if (confirmedSignatories[_transactionId][msg.sender]) {
            revert TransactionAlreadyConfirmedByThisSigner();
        }

        confirmedSignatories[_transactionId][msg.sender] = true;
        transaction.signatureCount++;

        if (transaction.signatureCount == quorum) {
            transaction.executionTime = block.timestamp + delayTime.getExecutionDuration();
        }



        executeTransaction(_transactionId); // check later 
    }

    function executeTransaction(uint256 _transactionId) internal {
        Transaction storage transaction = transactions[_transactionId];

        if (transaction.signatureCount != quorum) {
            revert QuorumNotEnough();
        }

        if (transaction.executed) {
            revert TransactionAlreadyExecuted();
        }

        if (transaction.executionTime == 0) {
            revert ExecutionTimeNotSet();
        }

        if (block.timestamp < transaction.executionTime) {
            revert DelayTimeNotElapsed();
        }

        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}("");
        require(success, "TransactionExecution failed");

        emit TransactionExecuted(_transactionId, transaction.to, transaction.value);
    }

    function cancelTransaction(uint256 _transactionId) external {
        if (!accessRoles.hasRole(accessRoles.getSignerRole(), msg.sender)) {
            revert NotASigner();
        }

        Transaction storage transaction = transactions[_transactionId];

        if (block.timestamp > transaction.executionTime) {
            revert TransactionAlreadyExecuted();
        }

        if (!transaction.created) {
            revert TransactionDoesntExist();
        }

        if (transaction.executed) {
            revert TransactionAlreadyExecuted();
        }
        
        if (transaction.signatureCount != quorum) {
            revert QuorumNotEnough();
        }

        if (transaction.signatureCount == quorum) {
            (bool success, ) = payable(transaction.to).call{value: proposalFee}("");
            require(success, "TransactionExecution failed");

            delete transactions[_transactionId];
        }

    
        
    }

    receive() external payable {};
    fallback() external payable {};
}
