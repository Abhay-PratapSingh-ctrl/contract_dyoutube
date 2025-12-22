// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

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

/* ------------------------------------------------ */
/* ---------------- CONTRACT ---------------------- */
/* ------------------------------------------------ */

contract X402AccessManager {
    /* ---------------- STATE ---------------- */

    ICreatorHub public immutable creatorHub;

    //Firebase backend wallet, The only address allowed to grant access
    address public paymentVerifier;

    // rental expiry: user => contentId => timestamp
    mapping(address => mapping(uint256 => uint256)) public rentedUntil;

    // permanent ownership
    mapping(address => mapping(uint256 => bool)) public ownsContent;

    event RentalGranted(
        address indexed user,
        uint256 indexed contentId,
        uint256 daysRented,
        uint256 expiresAt
    );

    event PurchaseGranted(address indexed user, uint256 indexed contentId);
    event VerifierUpdated(address indexed oldVerifier, address indexed newVerifier);

    /* ---------------- MODIFIERS ---------------- */

    modifier onlyVerifier() {
        require(msg.sender == paymentVerifier, "Not payment verifier");
        _;
    }

    /* ---------------- CONSTRUCTOR ---------------- */

    constructor(address _creatorHub, address _paymentVerifier) {
        require(_creatorHub != address(0), "Invalid CreatorHub");
        require(_paymentVerifier != address(0), "Invalid verifier");

        creatorHub = ICreatorHub(_creatorHub);
        // links to creatorhub contract
        paymentVerifier = _paymentVerifier;
    }
    function hasAccess(address user, uint256 contentId) public view returns (bool) {
        if (ownsContent[user][contentId]) return true;
        if (block.timestamp <= rentedUntil[user][contentId]) return true;
        return false;
    }
    
    //   Grant rental access after x402 payment verification
    //   user viewer wallet
    //   contentId content identifier
    //   daysRented number of days paid for (chosen by viewer)
   
    function grantRentalAccess(
        address user,
        uint256 contentId,
        uint256 daysRented
    ) external onlyVerifier {
        require(daysRented > 0, "Invalid rental duration");

        (
            ,
            ,
            ,
            bool isFree,
            ,
            uint256 rentedPrice,
            ,
            bool active
        ) = creatorHub.contents(contentId);

        require(active, "Content inactive");
        require(!isFree, "Free content");
        require(rentedPrice > 0, "Rental not enabled");

        uint256 duration = daysRented * 1 days;
        uint256 expiry;

        if (rentedUntil[user][contentId] > block.timestamp) {
            expiry = rentedUntil[user][contentId] + duration;
        } else {
            expiry = block.timestamp + duration;
        }

        rentedUntil[user][contentId] = expiry;

        emit RentalGranted(user, contentId, daysRented, expiry);
    }

    /**
     * @notice Grant permanent access after x402 payment verification
     */
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
            ,
            bool active
        ) = creatorHub.contents(contentId);

        require(active, "Content inactive");
        require(!isFree, "Free content");
        require(fullPrice > 0, "Purchase not enabled");
        require(!ownsContent[user][contentId], "Already owned");

        ownsContent[user][contentId] = true;

        emit PurchaseGranted(user, contentId);
    }

   
  function updateVerifier(address newVerifier) external onlyVerifier {
        require(newVerifier != address(0), "Invalid verifier");
        emit VerifierUpdated(paymentVerifier, newVerifier);
        paymentVerifier = newVerifier;
    }
}