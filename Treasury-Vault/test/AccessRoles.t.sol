// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {AccessRoles} from "../src/core/AccessRoles.sol";

contract AccessRolesTest is Test {
    AccessRoles accessRoles;

    address owner = address(1);
    address cosigner1 = address(2);
    address unauthorized = address(5);

    function setUp() public {
        accessRoles = new AccessRoles(owner, 2, 4);
    }

    function testAccessRoleInitialize() public {
        AccessRoles testAccessRoles = new AccessRoles(owner, 2, 4);
        assertEq(testAccessRoles.owner(), owner);
        assertEq(testAccessRoles.quorum(), 2);
        assertEq(testAccessRoles.totalSigners(), 4);
        assertTrue(testAccessRoles.hasRole(testAccessRoles.getDefaultAdminRole(), owner));
        assertTrue(testAccessRoles.hasRole(testAccessRoles.getSignerRole(), owner));
    }

    function testAddSigners() public {
        vm.prank(owner);
        address[] memory cosigners = new address[](1);
        cosigners[0] = cosigner1;
        accessRoles.addCosigners(cosigners);

        assertTrue(accessRoles.hasRole(accessRoles.getSignerRole(), cosigner1));
        assertEq(accessRoles.signers(0), cosigner1);
    }

    function testQuorum() public {
        vm.expectRevert(AccessRoles.QuorumIsGreaterThanTotalSigners.selector);
        new AccessRoles(owner, 4, 4);
    }

    function testForAddressZero() public {
        vm.expectRevert(AccessRoles.InvalidAddress.selector);
        new AccessRoles(address(0), 2, 4);
    }

    function testUnauthorizedAccess() public {
        vm.prank(unauthorized);
        address[] memory cosigners = new address[](1);
        cosigners[0] = cosigner1;

        vm.expectRevert();
        accessRoles.addCosigners(cosigners);
    }
}
