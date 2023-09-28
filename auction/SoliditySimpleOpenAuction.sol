// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract OpenAuction {
    // Auction params
    // Beneficiary receives money from the highest bidder
    address public beneficiary;
    uint256 public auctionStart;
    uint256 public auctionEnd;

    // Current state of auction
    address public highestBidder;
    uint256 public highestBid;

    // Set to true at the end, disallows any change
    bool public ended;

    // Keep track of refunded bids so we can follow the withdraw pattern
    mapping(address => uint256) public pendingReturns;

    // Create a simple auction with `_auction_start` and
    // `_bidding_time` seconds bidding time on behalf of the
    // beneficiary address `_beneficiary`.
    constructor(address _beneficiary, uint256 _auction_start, uint256 _bidding_time) {
        beneficiary = _beneficiary;
        auctionStart = _auction_start;  // auction start time can be in the past, present or future
        auctionEnd = auctionStart + _bidding_time;
        assert(block.timestamp < auctionEnd); // auction end time should be in the future
    }

    // Bid on the auction with the value sent
    // together with this transaction.
    // The value will only be refunded if the
    // auction is not won.
    function bid() external payable {
        // Check if bidding period has started.
        assert(block.timestamp >= auctionStart);
        // Check if bidding period is over.
        assert(block.timestamp < auctionEnd);
        // Check if bid is high enough
        assert(msg.value > highestBid);
        // Track the refund for the previous high bidder
        pendingReturns[highestBidder] += highestBid;
        // Track new high bid
        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    // Withdraw a previously refunded bid. The withdraw pattern is
    // used here to avoid a security issue. If refunds were directly
    // sent as part of bid(), a malicious bidding contract could block
    // those refunds and thus block new higher bids from coming in.
    function withdraw() public {
        uint256 amount = pendingReturns[msg.sender];
        pendingReturns[msg.sender] = 0;
        payable(msg.sender).call{value: amount}("");
    }

    // End the auction and send the highest bid
    // to the beneficiary.
    function endAuction() public {
        // 1. Conditions
        // Check if auction endtime has been reached
        assert(block.timestamp >= auctionEnd);
        // Check if this function has already been called
        assert(!ended);

        // 2. Effects
        ended = true;

        // 3. Interaction
        payable(beneficiary).call{value: highestBid}("");
    }
}
