// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/ContentAccessManager.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockCreatorHub.sol";

contract ContentAccessManagerTest is Test {
    ContentAccessManager manager;
    MockERC20 token;
    MockCreatorHub hub;

    address creator = address(0xA11CE);
    address user = address(0xB0B);

    uint256 constant CONTENT_ID = 1;
    uint256 constant FULL_PRICE = 10 ether;
    uint256 constant RENT_PRICE = 2 ether;

    function setUp() public {
        token = new MockERC20();
        hub = new MockCreatorHub();
        manager = new ContentAccessManager(address(hub));

        token.mint(user, 100 ether);

        vm.prank(user);
        token.approve(address(manager), type(uint256).max);

        hub.setContent(
            CONTENT_ID,
            creator,
            false, // isFree
            FULL_PRICE,
            RENT_PRICE,
            address(token),
            true // active
        );
    }

    //                ACCESS

    function testHasNoAccessInitially() public {
        assertFalse(manager.hasAccess(user, CONTENT_ID));
    }

    //      RENT

    function testRentContent() public {
        vm.prank(user);
        manager.rentContent(CONTENT_ID);

        uint256 expiry = manager.rentedUntil(user, CONTENT_ID);
        assertGt(expiry, block.timestamp);
        assertTrue(manager.hasAccess(user, CONTENT_ID));
    }

    function testRentExtendsAccess() public {
        vm.prank(user);
        manager.rentContent(CONTENT_ID);

        uint256 firstExpiry = manager.rentedUntil(user, CONTENT_ID);

        vm.warp(block.timestamp + 1 hours);

        vm.prank(user);
        manager.rentContent(CONTENT_ID);

        uint256 secondExpiry = manager.rentedUntil(user, CONTENT_ID);
        assertEq(secondExpiry, firstExpiry + 1 days);
    }

    function testRentRevertsIfInactive() public {
        hub.setContent(CONTENT_ID, creator, false, FULL_PRICE, RENT_PRICE, address(token), false);

        vm.prank(user);
        vm.expectRevert("Content inactive");
        manager.rentContent(CONTENT_ID);
    }

    function testRentRevertsIfFree() public {
        hub.setContent(CONTENT_ID, creator, true, 0, 0, address(token), true);

        vm.prank(user);
        vm.expectRevert("Content is free");
        manager.rentContent(CONTENT_ID);
    }

    //       BUY

    function testBuyContent() public {
        vm.prank(user);
        manager.buyContent(CONTENT_ID);

        assertTrue(manager.ownsContent(user, CONTENT_ID));
        assertTrue(manager.hasAccess(user, CONTENT_ID));
    }

    function testBuyRevertsIfAlreadyOwned() public {
        vm.prank(user);
        manager.buyContent(CONTENT_ID);

        vm.prank(user);
        vm.expectRevert("Already owned");
        manager.buyContent(CONTENT_ID);
    }

    function testBuyRevertsIfInactive() public {
        hub.setContent(CONTENT_ID, creator, false, FULL_PRICE, RENT_PRICE, address(token), false);

        vm.prank(user);
        vm.expectRevert("Content inactive");
        manager.buyContent(CONTENT_ID);
    }

    function testBuyRevertsIfFree() public {
        hub.setContent(CONTENT_ID, creator, true, 0, 0, address(token), true);

        vm.prank(user);
        vm.expectRevert("Content is free");
        manager.buyContent(CONTENT_ID);
    }
}
