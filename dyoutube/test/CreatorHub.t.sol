// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/CreatorHub.sol";

contract CreatorHubTest is Test {
    CreatorHub hub;

    address creator = address(0xA11CE);
    address creator2 = address(0xBEEF);
    address stranger = address(0xCAFE);

    address paymentToken = address(0xDEAD);

    function setUp() public {
        hub = new CreatorHub();

        // register & activate creator
        vm.prank(creator);
        hub.registerCreator("Alice", "Creator bio", "ipfs://creator");

        vm.prank(creator2);
        hub.registerCreator("Bob", "Another bio", "ipfs://bob");
    }

   
                 //      CREATE CONTENT
    

    function testCreateFreeContent() public {
        vm.prank(creator);
        uint256 contentId = hub.createContent(
            CreatorHub.ContentType.VIDEO,
            "ipfs://content1",
            true,   // isFree
            0,      // fullPrice
            0,      // rentedPrice
            address(0)
        );

        (
            address creatorAddress,
            CreatorHub.ContentType cType,
            string memory metadataURI,
            bool isFree,
            uint256 fullPrice,
            uint256 rentedPrice,
            address token,
            bool active
        ) = hub.contents(contentId);

        assertEq(creatorAddress, creator);
        assertEq(uint256(cType), uint256(CreatorHub.ContentType.VIDEO));
        assertEq(metadataURI, "ipfs://content1");
        assertTrue(isFree);
        assertEq(fullPrice, 0);
        assertEq(rentedPrice, 0);
        assertEq(token, address(0));
        assertTrue(active);
    }

    function testCreatePaidContent() public {
        vm.prank(creator);
        uint256 contentId = hub.createContent(
            CreatorHub.ContentType.ARTICLE,
            "ipfs://paid",
            false,
            10 ether,
            2 ether,
            paymentToken
        );

        (, , , bool isFree, uint256 fullPrice, uint256 rentedPrice, address token, ) =
            hub.contents(contentId);

        assertFalse(isFree);
        assertEq(fullPrice, 10 ether);
        assertEq(rentedPrice, 2 ether);
        assertEq(token, paymentToken);
    }

    function testRevertIfCreatorNotRegisteredOrInactive() public {
        vm.prank(stranger);
        vm.expectRevert("Only active creators can create content");
        hub.createContent(
            CreatorHub.ContentType.VIDEO,
            "ipfs://fail",
            true,
            0,
            0,
            address(0)
        );
    }

    function testRevertIfEmptyMetadata() public {
        vm.prank(creator);
        vm.expectRevert("Invalid metadataURI");
        hub.createContent(
            CreatorHub.ContentType.VIDEO,
            "",
            true,
            0,
            0,
            address(0)
        );
    }

    function testRevertInvalidFreePricing() public {
        vm.prank(creator);
        vm.expectRevert("Free content fullPrice must be 0");
        hub.createContent(
            CreatorHub.ContentType.VIDEO,
            "ipfs://bad",
            true,
            1 ether,
            0,
            address(0)
        );
    }

    function testRevertInvalidPaidPricing() public {
        vm.prank(creator);
        vm.expectRevert("Payment token required");
        hub.createContent(
            CreatorHub.ContentType.VIDEO,
            "ipfs://bad",
            false,
            5 ether,
            1 ether,
            address(0)
        );
    }

    
                       //  UPDATE CONTENT
   

    function testUpdateContent() public {
        vm.prank(creator);
        uint256 contentId = hub.createContent(
            CreatorHub.ContentType.VIDEO,
            "ipfs://old",
            true,
            0,
            0,
            address(0)
        );

        vm.prank(creator);
        hub.updateContent(
            contentId,
            CreatorHub.ContentType.PODCAST,
            "ipfs://new",
            10 ether,
            2 ether,
            paymentToken,
            false
        );

        (
            ,
            CreatorHub.ContentType cType,
            string memory metadataURI,
            bool isFree,
            uint256 fullPrice,
            uint256 rentedPrice,
            address token,

        ) = hub.contents(contentId);

        assertEq(uint256(cType), uint256(CreatorHub.ContentType.PODCAST));
        assertEq(metadataURI, "ipfs://new");
        assertFalse(isFree);
        assertEq(fullPrice, 10 ether);
        assertEq(rentedPrice, 2 ether);
        assertEq(token, paymentToken);
    }

    function testUpdateContentRevertsIfNotCreator() public {
        vm.prank(creator);
        uint256 contentId = hub.createContent(
            CreatorHub.ContentType.VIDEO,
            "ipfs://x",
            true,
            0,
            0,
            address(0)
        );

        vm.prank(stranger);
        vm.expectRevert("Only the content creator can update");
        hub.updateContent(
            contentId,
            CreatorHub.ContentType.ARTICLE,
            "ipfs://hack",
            0,
            0,
            address(0),
            true
        );
    }

    function testUpdateNonExistentContentReverts() public {
        vm.prank(creator);
        vm.expectRevert("Content does not exist");
        hub.updateContent(
            999,
            CreatorHub.ContentType.VIDEO,
            "ipfs://nope",
            0,
            0,
            address(0),
            true
        );
    }

   
     //                  SET CONTENT ACTIVE
  

    function testSetContentActive() public {
        vm.prank(creator);
        uint256 contentId = hub.createContent(
            CreatorHub.ContentType.VIDEO,
            "ipfs://content",
            true,
            0,
            0,
            address(0)
        );

        vm.prank(creator);
        hub.setContentActive(contentId, false);

        (, , , , , , , bool active) = hub.contents(contentId);
        assertFalse(active);
    }

    function testSetContentActiveRevertsIfNotCreator() public {
        vm.prank(creator);
        uint256 contentId = hub.createContent(
            CreatorHub.ContentType.VIDEO,
            "ipfs://content",
            true,
            0,
            0,
            address(0)
        );

        vm.prank(stranger);
        vm.expectRevert("Only the content creator can update its status");
        hub.setContentActive(contentId, false);
    }
}
