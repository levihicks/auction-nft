// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./AuctionNFT.sol";

contract AuctionHouse {
    using Counters for Counters.Counter;

    struct Auction {
        uint256 deadline;
        uint256 topBid;
        address topBidder;
    }

    Auction[100] public auctions;
    AuctionNFT public auctionNFTContract;
    Counters.Counter private _auctionIds;
    uint256 constant auctionDuration = 60 seconds;

    constructor(AuctionNFT _contract) {
        auctionNFTContract = _contract;
        settleAuction();
    }

    function settleAuction() public {
        uint256 currentAuctionId = _auctionIds.current();
        Auction memory currentAuction = auctions[currentAuctionId];
        require(currentAuctionId <= 100, "All auctions have ended.");
        require(
            block.timestamp > currentAuction.deadline,
            "This auction has not ended."
        );
        if (currentAuctionId >= 1 && currentAuction.topBidder != address(0))
            auctionNFTContract.mint(currentAuction.topBidder, currentAuctionId);
        if (currentAuctionId < 100) {
            _auctionIds.increment();
            auctions[_auctionIds.current()].deadline =
                block.timestamp +
                auctionDuration;
        }
    }

    function bid() public payable {
        uint256 currentAuctionId = _auctionIds.current();
        Auction memory currentAuction = auctions[currentAuctionId];
        require(
            block.timestamp < currentAuction.deadline,
            "This auction has ended."
        );
        require(
            msg.value > currentAuction.topBid,
            "Bid is not higher than top bid."
        );
        uint256 previousTopBid = auctions[currentAuctionId].topBid;
        address previousTopBidder = auctions[currentAuctionId].topBidder;
        auctions[currentAuctionId].topBid = msg.value;
        auctions[currentAuctionId].topBidder = msg.sender;
        (bool sent, ) = previousTopBidder.call{value: previousTopBid}("");
        require(sent, "Failed to send Ether");
    }
}
