// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19; // Remember to change the hardhat.config too to version the one you currently using 

contract AuctionContract {
    struct Item {
        address owner;
        string title;
        string description;
        uint256 startingPrice;
        uint256 auctionEndTime;
        address highestBidder;
        uint256 highestBid;
        bool ended;
        string image;
        address[] bidders;
        uint256[] bids;
    }

    mapping(uint256 => Item) public items;

    uint256 public numberOfItems = 0;

    function createAuction(address _owner, string memory _title, string memory _description, uint256 _startingPrice, uint256 _auctionEndTime, string memory _image) public returns (uint256) {
        Item storage newItem = items[numberOfItems];

        require(_auctionEndTime > block.timestamp, "Auction end time should be in the future.");

        newItem.owner = _owner;
        newItem.title = _title;
        newItem.description = _description;
        newItem.startingPrice = _startingPrice;
        newItem.auctionEndTime = _auctionEndTime;
        newItem.highestBidder = address(0);
        newItem.highestBid = 0;
        newItem.ended = false;
        newItem.image = _image;

        numberOfItems++;

        return numberOfItems - 1;
    }

    function bid(uint256 _id) public payable {
        require(block.timestamp <= items[_id].auctionEndTime, "Auction has ended.");
        require(msg.value > items[_id].highestBid, "Your bid is too low.");

        Item storage item = items[_id];

        if (item.highestBidder != address(0)) {
            payable(item.highestBidder).transfer(item.highestBid); 
        }

        item.highestBidder = msg.sender;
        item.highestBid = msg.value;

        item.bidders.push(msg.sender);
        item.bids.push(msg.value);
    }

    function endAuction(uint256 _id) public {
        require(block.timestamp >= items[_id].auctionEndTime, "Auction has not ended yet.");
        require(!items[_id].ended, "Auction already ended.");

        Item storage item = items[_id];

        item.ended = true;

        if (item.highestBidder != address(0)) {
            payable(item.owner).transfer(item.highestBid); 
        }
    }

    function getItemBids(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (items[_id].bidders, items[_id].bids);
    }

    function getItems() public view returns (Item[] memory) {
        Item[] memory allItems = new Item[](numberOfItems);

        for(uint i = 0; i < numberOfItems; i++) {
            Item storage currentItem = items[i];

            allItems[i] = currentItem;
        }

        return allItems;
    }
}






