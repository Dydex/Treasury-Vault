// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IAccessRoles} from "../interfaces/IAcessRoles.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IDelayTime} from "../interfaces/IDelayTime.sol";
import {Errors} from "../libraries/Errors.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TransactionProposal is ReentrancyGuard {
    IAccessRoles public accessRoles;

    IDelayTime public delayTime;

    IERC20 public token;

    uint256 public quorum;

    constructor(address _accessRoles, address _tokenAddress, address _delayTime) {
        accessRoles = IAccessRoles(_accessRoles);
        token = IERC20(_tokenAddress);
        delayTime = IDelayTime(_delayTime);

        quorum = accessRoles.getQuorum();
    }

    struct Transaction {
        address proposer;
        address to;
        uint256 value;
        bool executed;
        uint256 signatureCount;
        bool created;
        uint256 creationTime;
        uint256 executionTime;
    }
    uint256 public transactionCount;
    uint256 public proposalFee;

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmedSignatories;
    mapping(uint256 => mapping(address => bool)) public paidProposalFee;

    event TransactionExecuted(uint256 indexed transactionId, address indexed to, uint256 value);


    function setProposalFee(uint256 _fee) external {
        if (!accessRoles.hasRole(accessRoles.getDefaultAdminRole(), msg.sender)) {
            revert Errors.NotADefaultAdmin();
        }
        proposalFee = _fee;
    }

    function createTransaction(address _to, uint256 _value) external payable nonReentrant {
        if (proposalFee != msg.value) {
            revert Errors.InvalidProposalFee();
        }

        uint256 transactionId = transactionCount++;

        if (_to == address(0)) {
            revert Errors.InvalidAddress();
        }

        paidProposalFee[transactionId][msg.sender] = true;

        if (transactions[transactionId].created) {
            revert Errors.TransactionAlreadyExists();
        }

        transactions[transactionId] = Transaction({
            proposer: msg.sender,
            to: _to,
            value: _value,
            executed: false,
            signatureCount: 0,
            created: true,
            creationTime: block.timestamp,
            executionTime: 0
        });
    }

    function confirmTransaction(uint256 _transactionId) external nonReentrant {
        require(accessRoles.hasRole(accessRoles.getSignerRole(), msg.sender), "Not A Signers");

        Transaction storage transaction = transactions[_transactionId];

        if (transactions[_transactionId].signatureCount == quorum) {
            revert Errors.QuorumReached();
        }

        if (!transaction.created) {
            revert Errors.TransactionAlreadyExists();
        }

        if (transaction.executed) {
            revert Errors.TransactionAlreadyExecuted();
        }

        if (confirmedSignatories[_transactionId][msg.sender]) {
            revert Errors.TransactionAlreadyConfirmedByThisSigner();
        }

        confirmedSignatories[_transactionId][msg.sender] = true;
        transaction.signatureCount++;

        if (transaction.signatureCount == quorum) {
            transaction.executionTime = block.timestamp + delayTime.getExecutionDuration();
        }
    }

    function executeTransaction(uint256 _transactionId) external nonReentrant {
        if (!accessRoles.hasRole(accessRoles.getSignerRole(), msg.sender)) {
            revert Errors.NotASigner();
        }

        Transaction storage transaction = transactions[_transactionId];

        if (transaction.signatureCount != quorum) {
            revert Errors.QuorumNotEnough();
        }

        if (transaction.executed) {
            revert Errors.TransactionAlreadyExecuted();
        }

        if (transaction.executionTime == 0) {
            revert Errors.ExecutionTimeNotSet();
        }

        if (block.timestamp < transaction.executionTime) {
            revert Errors.DelayTimeNotElapsed();
        }

        if (transaction.signatureCount == quorum) {
            transaction.executed = true;

            token.transfer(transaction.to, transaction.value);
        }

        emit TransactionExecuted(_transactionId, transaction.to, transaction.value);
    }

    function cancelTransaction(uint256 _transactionId) external nonReentrant {
        if (!accessRoles.hasRole(accessRoles.getSignerRole(), msg.sender)) {
            revert Errors.NotASigner();
        }

        Transaction storage transaction = transactions[_transactionId];

        if (block.timestamp > transaction.executionTime) {
            revert Errors.TransactionAlreadyExecuted();
        }

        if (!transaction.created) {
            revert Errors.TransactionDoesntExist();
        }

        if (transaction.executed) {
            revert Errors.TransactionAlreadyExecuted();
        }

        if (transaction.signatureCount != quorum) {
            revert Errors.QuorumNotEnough();
        }

        if (transaction.signatureCount == quorum) {
            (bool success,) = payable(transaction.proposer).call{value: proposalFee}("");
            require(success, "TransactionExecution failed");

            delete transactions[_transactionId];
        }
    }

    receive() external payable {}
    fallback() external payable {}
}
