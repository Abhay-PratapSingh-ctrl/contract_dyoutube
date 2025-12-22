// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/CreatorRegistry.sol";

contract CreatorRegistryTest is Test {
    CreatorRegistry registry;

    address creator = address(0xA11CE);
    address stranger = address(0xB0B);

    function setUp() public {
        registry = new CreatorRegistry();
    }

    
       //                       REGISTER
    

    function testRegisterCreator() public {
        vm.prank(creator);
        registry.registerCreator(
            "Alice",
            "Web3 artist",
            "ipfs://metadata1"
        );

        (
            string memory name,
            string memory bio,
            string memory metadataURI,
            address walletAddress,
            bool active
        ) = registry.creators(creator);

        assertEq(name, "Alice");
        assertEq(bio, "Web3 artist");
        assertEq(metadataURI, "ipfs://metadata1");
        assertEq(walletAddress, creator);
        assertTrue(active);
    }

    function testRegisterCreatorOverwritesData() public {
        vm.prank(creator);
        registry.registerCreator("Alice", "Bio 1", "ipfs://1");

        vm.prank(creator);
        registry.registerCreator("Alice Updated", "Bio 2", "ipfs://2");

        (, string memory bio, string memory metadataURI,,) =
            registry.creators(creator);

        assertEq(bio, "Bio 2");
        assertEq(metadataURI, "ipfs://2");
    }

  
          //                UPDATE METADATA


    function testUpdateMetadata() public {
        vm.prank(creator);
        registry.registerCreator("Alice", "Bio", "ipfs://old");

        vm.prank(creator);
        registry.updateMetadata("ipfs://new");

        (, , string memory metadataURI,,) =
            registry.creators(creator);

        assertEq(metadataURI, "ipfs://new");
    }

    function testUpdateMetadataRevertsIfNotRegistered() public {
        vm.prank(stranger);
        vm.expectRevert("Creator not registered");
        registry.updateMetadata("ipfs://nope");
    }

        //                SET ACTIVE STATUS
  

    function testSetActiveStatus() public {
        vm.prank(creator);
        registry.registerCreator("Alice", "Bio", "ipfs://meta");

        vm.prank(creator);
        registry.setActiveStatus(false);

        (, , , , bool active) = registry.creators(creator);
        assertFalse(active);
    }

    function testSetActiveStatusRevertsIfNotRegistered() public {
        vm.prank(stranger);
        vm.expectRevert("Creator not registered");
        registry.setActiveStatus(false);
    }
}
