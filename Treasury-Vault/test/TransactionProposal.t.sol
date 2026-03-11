// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {TransactionProposal} from "../src/core/TransactionProposal.sol";
import {AccessRoles} from "../src/core/AccessRoles.sol";
import {DelayTime} from "../src/core/DelayTime.sol";

contract TransactionProposalTest is Test {
    TransactionProposal public proposal;
    AccessRoles public accessRoles;
    DelayTime public delayTime;

    address admin = address(1);
    address signer1 = address(2);
    address signer2 = address(3);
    address attacker = address(4);
    address recipient = address(5);
    address token = address(6);

    function setUp() external {
        vm.deal(admin, 100 ether);
        vm.deal(signer1, 100 ether);
        vm.deal(signer2, 100 ether);
        vm.deal(attacker, 100 ether);

        vm.startPrank(admin);
        accessRoles = new AccessRoles(admin, 2, 3);

        address[] memory cosigners = new address[](2);
        cosigners[0] = signer1;
        cosigners[1] = signer2;
        accessRoles.addCosigners(cosigners);

        delayTime = new DelayTime(address(accessRoles));
        delayTime.setExecutionDuration(1);

        proposal = new TransactionProposal(address(accessRoles), token, address(delayTime));
        proposal.setProposalFee(1 ether);

        vm.stopPrank();
    }

    function testDoubleConfirmationAttempt() external {
        vm.prank(admin);
        proposal.createTransaction{value: 1 ether}(recipient, 10 ether);

        vm.prank(signer1);
        proposal.confirmTransaction(0);

        vm.prank(signer1);
        vm.expectRevert(TransactionProposal.TransactionAlreadyConfirmedByThisSigner.selector);
        proposal.confirmTransaction(0);
    }

    function testUnauthorizedSignerConfirm() external {
        vm.prank(admin);
        proposal.createTransaction{value: 1 ether}(recipient, 10 ether);

        vm.prank(attacker);
        vm.expectRevert("Not A Signers");
        proposal.confirmTransaction(0);
    }

    function testPrematureExecution() external {
        vm.prank(admin);
        proposal.createTransaction{value: 1 ether}(recipient, 10 ether);

        vm.prank(signer1);
        proposal.confirmTransaction(0);

        vm.prank(signer2);
        proposal.confirmTransaction(0);

        vm.prank(signer1);
        vm.expectRevert(TransactionProposal.DelayTimeNotElapsed.selector);
        proposal.executeTransaction(0);
    }

    function testInvalidProposalFee() external {
        vm.prank(admin);
        vm.expectRevert(TransactionProposal.InvalidProposalFee.selector);
        proposal.createTransaction{value: 0.5 ether}(recipient, 10 ether);
    }

    function testSuccessfulCancelTransaction() external {
        vm.prank(admin);
        proposal.createTransaction{value: 1 ether}(recipient, 10 ether);

        vm.prank(signer1);
        proposal.confirmTransaction(0);

        vm.prank(signer2);
        proposal.confirmTransaction(0);

        uint256 balanceBefore = admin.balance;

        vm.prank(signer1);
        proposal.cancelTransaction(0);

        uint256 balanceAfter = admin.balance;
        assertEq(balanceAfter, balanceBefore + 1 ether);
    }
}

