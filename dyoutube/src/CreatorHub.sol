//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import "./CreatorRegistry.sol";

contract CreatorHub is CreatorRegistry {
    // Additional functionalities can be added here in the future
    enum ContentType {
        VIDEO,
        ARTICLE,
        PODCAST,
        AUDIO,
        NEWSLETTER,
        OTHER
    }

    /*It is simply a link stored on-chain that points to a file stored off-chain (Walrus/Filecoin/IPFS).
    That file contains your actual data like:

    display name

    bio / description

    images

    content title

    file URIs (videos, audio, article body)

    📌 In Solidity we only store the link (string), not the whole data.
    Because blockchain storage is expensive.*/

    struct Content {
        address creatorAddress;
        ContentType cType;
        // ctype tells us how to render (player or article)
        string metadataURI;
        bool isFree;
        uint256 fullPrice;
        uint256 rentedPrice; // per access price
        // rented price is for renting the content
        // full price is for buying the content
        address paymentToken; // address of the token contract
        bool active;
    }
    uint256 public nextContentId;
    mapping(uint256 => Content) public contents;

    function createContent(
        ContentType cType,
        string memory metadataURI,
        bool isFree,
        uint256 fullPrice,
        uint256 rentedPrice,
        address paymentToken
    ) external returns (uint256) {
        // only registered creators can create content
        require(creators[msg.sender].active, "Only active creators can create content");
        require(bytes(metadataURI).length > 0, "Invalid metadataURI");
        // create content logic here
        if (isFree) {
            require(fullPrice == 0, "Free content fullPrice must be 0");
            require(rentedPrice == 0, "Free content rentedPrice must be 0");
        } else {
            require(paymentToken != address(0), "Payment token required");
            require(rentedPrice > 0, "rentedPrice must be > 0");
            require(fullPrice >= rentedPrice, "fullPrice must be >= rentedPrice");
        }
        uint256 contentId = nextContentId++;
        //somewhat we r about to create an array
        contents[contentId] = Content({
            creatorAddress: msg.sender,
            cType: cType,
            metadataURI: metadataURI,
            isFree: isFree,
            fullPrice: fullPrice,
            rentedPrice: rentedPrice,
            paymentToken: paymentToken,
            active: true
        });
        return contentId;
        //it will return content id
    }

    function updateContent(
        uint256 contentId,
        ContentType cType,
        string memory metadataURI,
        uint256 fullPrice,
        uint256 rentedPrice,
        address paymentToken,
        bool isFree
    ) external {
        // only the creator who created the content can update it
        Content storage c = contents[contentId];
        require(c.creatorAddress != address(0), "Content does not exist");
        require(c.creatorAddress == msg.sender, "Only the content creator can update");
        // update content logic here
        if (isFree) {
            require(fullPrice == 0, "Free content fullPrice must be 0");
            require(rentedPrice == 0, "Free content rentedPrice must be 0");
        } else {
            require(paymentToken != address(0), "Payment token required");
            require(rentedPrice > 0, "rentedPrice must be > 0");
            require(fullPrice >= rentedPrice, "fullPrice must be >= rentedPrice");
        }
        c.cType = cType;
        c.metadataURI = metadataURI;
        c.isFree = isFree;
        c.fullPrice = fullPrice;
        c.rentedPrice = rentedPrice;
        c.paymentToken = paymentToken;
    }

    function setContentActive(uint256 contentId, bool status) external {
        // only the creator who created the content can update its active status
        Content storage c = contents[contentId];
        require(c.creatorAddress != address(0), "Content does not exist");
        require(c.creatorAddress == msg.sender, "Only the content creator can update its status");

        c.active = status;
    }
}
