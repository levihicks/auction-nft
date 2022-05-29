// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./AuctionNFT.sol";

/// @title AuctionHouse
/// @author Levi Hicks
/// @notice executes individual auctions of the supply of an NFT
contract AuctionHouse {
    using Counters for Counters.Counter;

    /// === Structs ===

    /// @notice Data for an auction
    struct Auction {
        uint256 deadline;
        uint256 topBid;
        address topBidder;
    }

    /// === Storage ===

    uint256 constant MAX_SUPPLY = 100; // max supply of tokens
    uint256 constant AUCTION_DURATION = 60 seconds; // length of each auction

    Auction[MAX_SUPPLY] public auctions; // array of auctions for each NFT
    AuctionNFT public auctionNFTContract; // the NFT to be used in auctions
    Counters.Counter private _auctionIds; // counter for maintaining the id of the current auction

    /// === Constructor ===

    /// @notice constructor
    /// @param _contract address of the NFT contract
    constructor(AuctionNFT _contract) {
        auctionNFTContract = _contract;
        settleAuction();
    }

    /// === Functions ===

    /// @notice settles auction if one has ended and begins new auction
    ///     if max supply has not been minted
    function settleAuction() public {
        uint256 currentAuctionId = _auctionIds.current();
        Auction memory currentAuction = auctions[currentAuctionId];
        require(currentAuctionId <= MAX_SUPPLY, "All auctions have ended.");
        require(
            block.timestamp > currentAuction.deadline,
            "This auction has not ended."
        );
        if (currentAuctionId >= 1 && currentAuction.topBidder != address(0))
            auctionNFTContract.mint(currentAuction.topBidder, currentAuctionId);
        if (currentAuctionId < MAX_SUPPLY) {
            _auctionIds.increment();
            auctions[_auctionIds.current()].deadline =
                block.timestamp +
                AUCTION_DURATION;
        }
    }

    /// @notice places a new bid during an auction and refunds the previous top bidder
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
        if (previousTopBidder != address(0)) {
            (bool sent, ) = previousTopBidder.call{value: previousTopBid}("");
            require(sent, "Failed to send Ether");
        }
    }
}
