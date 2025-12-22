//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract CreatorRegistry {
    struct creator {
        string name;
        string bio;
        string metadataURI;
        address walletAddress;
        bool active;
    }
    // struct viewer{
    //     string name;
    //     string bio;
    //     string profileImage;
    //     address walletAddress;
    //     bool active;
    mapping(address => creator) public creators;

    // mapping(address => viewer) public viewers;

    //functions now
    function registerCreator(string memory _name, string memory _bio, string memory _metadataURI) public {
        creators[msg.sender] = creator(_name, _bio, _metadataURI, msg.sender, true);
    }

    // registerViewer(string metadataURI){
    //     viewers[msg.sender] = viewer(metadataURI, msg.sender);
    // }

    // in order to update their profile {profile image}
    function updateMetadata(string memory newMetadataURI) public {
        creators[msg.sender].metadataURI = newMetadataURI;
        require(creators[msg.sender].walletAddress != address(0), "Creator not registered");
    }

    function setActiveStatus(bool status) public {
        creators[msg.sender].active = status;
        require(creators[msg.sender].walletAddress != address(0), "Creator not registered");
    }
}
