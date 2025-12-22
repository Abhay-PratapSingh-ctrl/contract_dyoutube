// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface ICreatorHub {
    function contents(uint256 contentId)
        external
        view
        returns (
            address,
            uint8,
            string memory,
            bool,
            uint256,
            uint256,
            address,
            bool
        );
}

contract X402AccessManager {
    ICreatorHub public immutable creatorHub;
    address public immutable USDC;
    address public paymentVerifier;

    mapping(address => mapping(uint256 => uint256)) public rentedUntil;
    mapping(address => mapping(uint256 => bool)) public ownsContent;

    modifier onlyVerifier() {
        require(msg.sender == paymentVerifier, "Not payment verifier");
        _;
    }

    constructor(
        address _creatorHub,
        address _usdc,
        address _verifier
    ) {
        require(_creatorHub != address(0), "Invalid CreatorHub");
        require(_usdc != address(0), "Invalid USDC");
        require(_verifier != address(0), "Invalid verifier");

        creatorHub = ICreatorHub(_creatorHub);
        USDC = _usdc;
        paymentVerifier = _verifier;
    }

    function hasAccess(address user, uint256 contentId) public view returns (bool) {
        return
            ownsContent[user][contentId] ||
            block.timestamp <= rentedUntil[user][contentId];
    }

    function grantRentalAccess(
        address user,
        uint256 contentId,
        uint256 daysRented
    ) external onlyVerifier {
        require(daysRented > 0, "Invalid days");

        (
            ,
            ,
            ,
            bool isFree,
            ,
            uint256 rentedPrice,
            address paymentToken,
            bool active
        ) = creatorHub.contents(contentId);

        require(active, "Content inactive");
        require(!isFree, "Free content");
        require(rentedPrice > 0, "Rental disabled");
        require(paymentToken == USDC, "Only USDC supported");

        uint256 duration = daysRented * 1 days;

        if (rentedUntil[user][contentId] > block.timestamp) {
            rentedUntil[user][contentId] += duration;
        } else {
            rentedUntil[user][contentId] = block.timestamp + duration;
        }
    }

    function grantPurchaseAccess(address user, uint256 contentId)
        external
        onlyVerifier
    {
        (
            ,
            ,
            ,
            bool isFree,
            uint256 fullPrice,
            ,
            address paymentToken,
            bool active
        ) = creatorHub.contents(contentId);

        require(active, "Content inactive");
        require(!isFree, "Free content");
        require(fullPrice > 0, "Purchase disabled");
        require(paymentToken == USDC, "Only USDC supported");
        require(!ownsContent[user][contentId], "Already owned");

        ownsContent[user][contentId] = true;
    }
}
