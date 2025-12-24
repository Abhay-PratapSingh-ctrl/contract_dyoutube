// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MockCreatorHub {
    struct Content {
        address creator;
        bool isFree;
        uint256 fullPrice;
        uint256 rentedPrice;
        address paymentToken;
        bool active;
    }

    mapping(uint256 => Content) public mockContents;

    function setContent(
        uint256 id,
        address creator,
        bool isFree,
        uint256 fullPrice,
        uint256 rentedPrice,
        address paymentToken,
        bool active
    ) external {
        mockContents[id] = Content(creator, isFree, fullPrice, rentedPrice, paymentToken, active);
    }

    function contents(uint256 contentId)
        external
        view
        returns (
            address creatorAddress,
            uint8,
            string memory,
            bool isFree,
            uint256 fullPrice,
            uint256 rentedPrice,
            address paymentToken,
            bool active
        )
    {
        Content memory c = mockContents[contentId];
        return (c.creator, 0, "", c.isFree, c.fullPrice, c.rentedPrice, c.paymentToken, c.active);
    }
}
