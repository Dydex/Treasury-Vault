// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library Errors {
    // AccessRoles Errors
    error QuorumIsGreaterThanTotalSigners();
    error CoSignersAreGreaterThanTotalSigners();
    error SignerAlreadyExists();
    error InvalidAddress();
    error NotADefaultAdmin();

    // Treasury Errors
    error InvalidAmount();
    error InsufficientFunds();
    error OnlyTreasuryCanCallThisFunction();

    // TransactionProposal Errors
    error QuorumReached();
    error TransactionAlreadyExists();
    error NotASigner();
    error InvalidProposalFee();
    error TransactionAlreadyExecuted();
    error TransactionAlreadyConfirmedByThisSigner();
    error QuorumNotEnough();
    error ExecutionTimeNotSet();
    error DelayTimeNotElapsed();
    error TransactionDoesntExist();
    

    // ClaimDistribution Errors
    error AlreadyClaimed();
    error InvalidProof();
    error TransferFailed();
}
