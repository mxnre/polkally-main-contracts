// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */


pragma solidity ^0.8.0;
pragma abicoder v2;

import "./ContractBase.sol";
import "./Category.sol";
import "./TransferBase.sol";

contract Auction is ContractBase, Category, TransferBase {
    using SafeMath for uint256;

    event NewAuction(uint256 _id);
    event AuctionCancelled(uint256 _id);
    event AuctionEnded(uint256 _id);
    event NewBid(address indexed _bidder, uint256 _id, uint256 _amount);
    event BidWithdrawn(address indexed _bidder, uint256 _id, uint256 _bidId);

    /**
     * initialize contract
     */
    constructor(address storeAddress) {
        initializeDataStore(storeAddress);
    }

    /**
     * new Auction
     * @param  _categoryId   - Category Id
     * @param  _assetContract   - Asset Contract address
     * @param  _tokenId   -  the Id of Token
     * @param  _price   -  the asking Price
     * @param  _paymentToken   - the token address for payment
     * @param  _startTime   - the auction start Time
     * @param  _endTime     - the auction end Time
     * @param  _isLimited   - is Time Limited Auction or OpenBid?
     */
    function create(
        uint256           _categoryId,
        address           _assetContract,
        uint256           _tokenId,
        uint256           _price,
        address           _paymentToken,
        uint256           _startTime,
        uint256           _endTime,
        bool              _isLimited
    ) public returns(uint256) {

        require(_price > 0, "Auction#create: INVALID_PRICE");

        //lets save new data
        uint256 newItemId = _dataStore.nextMarketItemId();

        PriceInfo memory _priceInfo = PriceInfo({
            paymentToken:    _paymentToken,
            value:           _price
        });

        AuctionData memory _auction = AuctionData({
            isTimeLimted:    _isLimited,
            startTime:       _isLimited ? _startTime : 0,
            endTime:         _isLimited ? _endTime : 0
        });

        MarketItem memory _item;
        _item.id               = newItemId;
        _item.categoryId       = _categoryId;
        _item.bidType          = (_isLimited ? TIMED_ASSET_TYPE : OPENBID_ASSET_TYPE);
        _item.assetType        = ERC721_ASSET_TYPE;
        _item.assetContract    = _assetContract;
        _item.tokenId          = _tokenId;
        _item.count            = 1;
        _item.owner            = _msgSender();
        _item.askingPrice      = _priceInfo;
        _item.auctionData      = _auction;
        _item.isActive         = true;
        _item.createdAt        = block.timestamp;
        _item.updatedAt        = block.timestamp;

        _dataStore.saveMarketItem(newItemId, _item);

        // Transfer Asset To Auction Contract.
        transfer(ERC721_ASSET_TYPE, _assetContract, _tokenId, _msgSender(), address(this), 1);

        emit NewAuction(newItemId);

        return newItemId;
    } //end



    /**
     * Cancel Auction by Auction Creator
     * @param _id uint256 ID of the created auction
     */
    function cancelAuction(uint256 _id) public onlyAuctionOwner(_id) {
        MarketItem memory item = _dataStore.getMarketItem(_id);
        uint bidsLength = _dataStore.getBidsLengthForAuction(_id);

        require(bidsLength == 0, "Auction#cancelAuction: bid already started");

        // refund Asset to owner of auction
        transfer(ERC721_ASSET_TYPE, item.assetContract, item.tokenId, address(this), _msgSender(), 1);

        _dataStore.delMarketItem(_id);

        emit AuctionCancelled(_id);
    }


    /**
     * Finalize Timed Auction by Auction Creator
     * @param _id uint256 ID of the created auction
     * @param _bidId uint256 ID of winning Bid. for timelimited auction it will be not used
     */
    function finalizeAuction(uint256 _id, uint256 _bidId) public onlyAuctionOwner(_id) {
        MarketItem memory item = _dataStore.getMarketItem(_id);
        require(item.isActive, "Auction#finalizeAuction: Auction is not acitve");
        require(item.auctionData.endTime < block.timestamp, "Auction#finalizeAuction: Auction is not over yet");

        if(_dataStore.getBidsLengthForAuction(_id) == 0) {
            // There is no any bids. simply cancel auction
            cancelAuction(_id);
        } else {
            if(item.auctionData.isTimeLimted) {
                Bid memory winningBid = _dataStore.getWinningBidForAuction(_id);
                // transfer funds to auction creator
                if(winningBid.value > 0) {
                    transfer(ERC20_ASSET_TYPE, winningBid.currency, 0, address(this), _msgSender(), winningBid.value);
                }
            } else {
                Bid memory choosenBid = _dataStore.getBidFromId(_bidId);
                require(choosenBid.isActive && choosenBid.value > 0, "Auction#finalizeAuction: Selected bid is not active");

                transfer(ERC721_ASSET_TYPE, item.assetContract, item.tokenId, address(this), choosenBid.bidder, 1);
                transfer(ERC20_ASSET_TYPE, choosenBid.currency, 0, address(this), _msgSender(), choosenBid.value);

                _dataStore.closeBid(_bidId);
            }

            _dataStore.delMarketItem(_id);
            emit AuctionEnded(_id);
        }
    }

    /**
     *  Bidder sends bid on an auction
     *  Auction should be active and not ended
     * @param _id uint256 ID of the created auction
     * @param amount uint256 amount of bid
     */
    function placeBid(uint256 _id, address currency, uint256 amount) public {
        // owner can't bid on their auctions
        MarketItem memory item = _dataStore.getMarketItem(_id);
        require(item.isActive, "Auction#placeBid: Auction is not acitve");
        require(item.owner != _msgSender(), "Auction#placeBid: owner can not bid");
        require(!item.auctionData.isTimeLimted || item.askingPrice.paymentToken == currency, "Auction#placeBid: Only OpenBid supports custom Token Payment");

        // Check already placed bid
        Bid memory oldBid = _dataStore.getUserBidForAuction(_id, _msgSender());
        require(!oldBid.isActive || oldBid.currency == currency, "Auction#placeBid: not matched with old bid");


        uint256 tempAmount = item.askingPrice.value;
        // if auction is timelimited auction
        if(item.auctionData.isTimeLimted) {
            require(block.timestamp < item.auctionData.endTime, "Auction#placeBid: auction is over");
            require(block.timestamp >= item.auctionData.startTime, "Auction#placeBid: auction is not started");

            // check if bid amount is bigger than lastBid
            if(_dataStore.getBidsLengthForAuction(_id) > 0) {
                Bid memory lastBid = _dataStore.getWinningBidForAuction(_id);
                tempAmount = lastBid.value;
            }
        }

        require(amount > tempAmount, "Auction#placeBid: TOO_SMALL_AMOUNT");

        // transfer Payment Token to Auction contract from bidder
        transfer(ERC20_ASSET_TYPE, item.askingPrice.paymentToken, 0, _msgSender(), address(this), amount);

        // check already placed bid
        if(oldBid.isActive) {
            _dataStore.increaseBid(_id, oldBid.id, amount);
        }
        else {
            // add bid to Store
            Bid memory newBid;
            uint256 newBidId = _dataStore.nextBidId();
            newBid.id         = newBidId;
            newBid.marketId   = _id;
            newBid.bidder     = _msgSender();
            newBid.currency   = currency;
            newBid.value      = amount;
            newBid.isActive   = true;
            newBid.createdAt  = block.timestamp;

            _dataStore.addBid(_id, newBid);
        }

        emit NewBid(_msgSender(), _id, amount);
    }

    /**
     *  Bidder withdraw Bid
     *  Bid should be active
     *  TimedAuction: Bidder can withdraw only after Auction ended and decided winning bid
     *  OpenBid:  Bidder can withdraw anytime
     * @param _id uint256 ID of the created auction
     */
    function withdrawBid(uint256 _id) public {
        MarketItem memory item = _dataStore.getMarketItem(_id);
        Bid memory bid = _dataStore.getUserBidForAuction(_id, _msgSender());
        require(bid.bidder == _msgSender(), "Auction#withdrawBid: NOT_OWNER");
        require(bid.isActive, "Auction#withdrawBid: BID_NOT_ACTIVE");

        if(item.auctionData.isTimeLimted) {
            require(item.auctionData.endTime < block.timestamp, "Auction#withdrawBid: Time limited auction is not over yet");
            Bid memory winningBid = _dataStore.getWinningBidForAuction(_id);
            if(bid.id == winningBid.id) {
                // If this bid is winning Bid of timelimited auction
                // transfer Item to winning bidder
                transfer(ERC721_ASSET_TYPE, item.assetContract, item.tokenId, address(this), _msgSender(), 1);
            } else {
                // If this bid is not winning bid, refund funds
                transfer(ERC20_ASSET_TYPE, bid.currency, 0, address(this), _msgSender(), bid.value);
            }
        } else {
            // If this auction is open bid, bidder can withdraw anytime
            transfer(ERC20_ASSET_TYPE, bid.currency, 0, address(this), _msgSender(), bid.value);
        }

        // close Bid item
        _dataStore.closeBid(bid.id);

        emit BidWithdrawn(_msgSender(), _id, bid.id);
    }



    modifier onlyAuctionOwner(uint _id) {
        require(_dataStore.getMarketItem(_id).owner == _msgSender());
        _;
    }
}
