// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICreatorHub {
    function contents(uint256 contentId)
        external
        view
        returns (
            address creatorAddress,
            uint8 cType,
            string memory metadataURI,
            bool isFree,
            uint256 fullPrice,
            uint256 rentedPrice,
            address paymentToken,
            bool active
        );
}

contract ContentAccessManager {
    ICreatorHub public creatorHub;

    // Rental access expiry, stores the timestamp until which the user has access
    mapping(address => mapping(uint256 => uint256)) public rentedUntil;

    // Full purchase ownership, once true user has permanent access
    mapping(address => mapping(uint256 => bool)) public ownsContent;

    uint256 public constant RENT_DURATION = 1 days;

    event ContentRented(address indexed user, uint256 indexed contentId, uint256 until);
    event ContentPurchased(address indexed user, uint256 indexed contentId);

    constructor(address _creatorHub) {
        creatorHub = ICreatorHub(_creatorHub);
    }

    function hasAccess(address user, uint256 contentId) public view returns (bool) {
        if (ownsContent[user][contentId]) return true;
        if (block.timestamp <= rentedUntil[user][contentId]) return true;
        return false;
    }

    // Rent content for a limited time one day
    function rentContent(uint256 contentId) external {
        (address creator,,, bool isFree,, uint256 rentedPrice, address paymentToken, bool active) =
            creatorHub.contents(contentId);

        require(active, "Content inactive");
        require(!isFree, "Content is free");
        require(rentedPrice > 0, "Rental not available");

        IERC20(paymentToken).transferFrom(msg.sender, creator, rentedPrice);
        require(IERC20(paymentToken).transferFrom(msg.sender, creator, rentedPrice), "Token transfer failed");

        uint256 newExpiry = block.timestamp + RENT_DURATION;

        // extend rental if already rented
        if (rentedUntil[msg.sender][contentId] > block.timestamp) {
            rentedUntil[msg.sender][contentId] += RENT_DURATION;
        } else {
            rentedUntil[msg.sender][contentId] = newExpiry;
        }

        emit ContentRented(msg.sender, contentId, rentedUntil[msg.sender][contentId]);
    }

    // Buy content permanently
    function buyContent(uint256 contentId) external {
        (address creator,,, bool isFree, uint256 fullPrice,, address paymentToken, bool active) =
            creatorHub.contents(contentId);

        require(active, "Content inactive");
        require(!isFree, "Content is free");
        require(fullPrice > 0, "Purchase not available");
        require(!ownsContent[msg.sender][contentId], "Already owned");

        IERC20(paymentToken).transferFrom(msg.sender, creator, fullPrice);
        require(IERC20(paymentToken).transferFrom(msg.sender, creator, fullPrice), "Token transfer failed");

        ownsContent[msg.sender][contentId] = true;

        emit ContentPurchased(msg.sender, contentId);
    }
}
