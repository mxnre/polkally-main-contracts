// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;


import "./StoreCore.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../StructsDef.sol";
import "./StoreVars.sol";

contract  CustomStore is StructsDef, StoreVars, StoreCore {

   //lets set variables
    using SafeMath for uint256;

    //acounts deposit info
    //mapping(address => StructsDef.AccountInfo) private creators;

    mapping(uint256 => StructsDef.CategoryInfo) private _categories;

    function setInitialized() public onlyDataWriter {
        require(!initialized, "KALLY_DATA_STORE: ALREADY_INITIALIZED");
        initialized    = true;
    }

    ///////////////// CONFIG ////////////////


    // main config
    StructsDef.ConfigsData  public _mainConfig;

    // get config
    function getMainConfigs() public view returns (ConfigsData memory) {
        return _mainConfig;
    }
    //////////////// END CONFIG //////////////

    /////////////////// START CATEGORIES //////////////////////////

    function nextCategoryId() public onlyDataWriter returns(uint256){
        return ++totalCategories;
    }

    function getCategory(uint256 _id) public view returns(CategoryInfo memory) {
        return  _categories[_id];
    }

    function saveCategory(uint256 _id, CategoryInfo memory _catInfo) public onlyDataWriter {
        _categories[_id] =  _catInfo;
    }

    function setTotalDisabledCategories(uint256 _value) public onlyDataWriter {
        totalDisabledCategories = _value;
    }
    /////////////////////// END CATEGORIES ////////////////////////



    /////////////////// START Market Items //////////////////////////

    // Market Item Info
    // marketItem Id => Item
    mapping(uint256 => StructsDef.MarketItem) private _marketItems;

    // All Bid Info
    // bidId => Bid
    mapping(uint256 => StructsDef.Bid) private _itemBids;

    // Bid Ids for auctionId
    // marketItemId => bidIDs
    mapping(uint256 => uint256[]) private _auctionBids;

    // Bid Ids for auctionId and bidder address
    // marketItemId => (address => BidId)
    mapping(uint256 => mapping(address => uint256)) private _auctionUserBids;

    //marketItemId => winningBid ID
    mapping(uint256 => uint256) private _winningBidId;

    function nextMarketItemId() public onlyDataWriter returns(uint256){
        return ++totalMarketItems;
    }

    function getMarketItem(uint256 _id) public view returns(MarketItem memory) {
        return  _marketItems[_id];
    }

    function saveMarketItem(uint256 _id, MarketItem memory _marketInfo) public onlyDataWriter {
        _marketItems[_id] =  _marketInfo;
    }

    function delMarketItem(uint256 _id) public onlyDataWriter {
        _marketItems[_id].isActive  =  false;
        _marketItems[_id].count     =  0;
        _marketItems[_id].updatedAt =  block.timestamp;
    }


    function nextBidId() public onlyDataWriter returns(uint256){
        return ++totalBids;
    }

    function addBid(uint256 _id, Bid memory bid) public onlyDataWriter {
        _itemBids[bid.id] = bid;
        _auctionBids[_id].push(bid.id);
        _auctionUserBids[_id][bid.bidder] = bid.id;

        // check Winning Bid
        Bid memory prevWinningBid = _itemBids[_winningBidId[_id]];
        if(!prevWinningBid.isActive || prevWinningBid.value < bid.value) {
            _winningBidId[_id] = bid.id;
        }
    }

    function increaseBid(uint256 _id, uint256 bidId, uint256 _amount) public onlyDataWriter {
        _itemBids[bidId].value = _itemBids[bidId].value.add(_amount);

         // check Winning Bid
        Bid memory prevWinningBid = _itemBids[_winningBidId[_id]];
        if(!prevWinningBid.isActive || prevWinningBid.value < _itemBids[bidId].value) {
            _winningBidId[_id] = bidId;
        }
    }

    function closeBid(uint256 _bidId) public onlyDataWriter {
        _itemBids[_bidId].isActive = false;
    }

    function getBidFromId(uint256 _bidId) public view returns(Bid memory) {
        return _itemBids[_bidId];
    }

    function getBidIdsForAuction(uint256 _id) public view returns (uint256[] memory) {
        return _auctionBids[_id];
    }

    function getBidsLengthForAuction(uint256 _id) public view returns(uint256) {
        return _auctionBids[_id].length;
    }

    function getUserBidForAuction(uint256 _id, address bidder) public view returns(Bid memory) {
        return _itemBids[_auctionUserBids[_id][bidder]];
    }

    function getWinningBidForAuction(uint256 _id) public view returns(Bid memory) {
        return _itemBids[_winningBidId[_id]];
    }

    /////////////////////// END Market Items ////////////////////////

    ///////////////////// START BIDS ////////////////////////////////////
    /**
     * @dev add user bid to history, this will enable us to get user history as fast as possible, without
     * scanning through numerous
     * @param _account the account to add bid id to
     * @param _bidId the bid id to add
     */
    function addUserBidHistory(address _account, uint256 _bidId) public onlyDataWriter {
        _userBidHistory[_account].push(_bidId);
    }
    ///////////////////// END BIDS /////////////////////////////////

    ///////////////////// START Collections /////////////////////////////////
    mapping(uint256 => StructsDef.Collection) private _collections;

    function nextCollectionId() public onlyDataWriter returns(uint256){
        return ++totalCollections;
    }

    function getCollection(uint256 _id) public view returns(Collection memory) {
        return  _collections[_id];
    }

    function saveCollection(uint256 _id, Collection memory _collection) public onlyDataWriter {
        _collections[_id] =  _collection;
    }
    ///////////////////// END Collections /////////////////////////////////

    ///////////////////// START Collections 1 /////////////////////////////////
    mapping(uint256 => StructsDef.Collection1) private _collections1;

    function nextCollection1Id() public onlyDataWriter returns(uint256){
        return ++totalCollections1;
    }

    function getCollection1(uint256 _id) public view returns(Collection1 memory) {
        return  _collections1[_id];
    }

    function saveCollection1(uint256 _id, Collection1 memory _collection1) public onlyDataWriter {
        _collections1[_id] =  _collection1;
    }

    function addToCollection1(uint256 _id, uint256 _tokenId) public {
        Collection1 storage coll1 = _collections1[_id];
        bool isNew = true;
        for (uint256 i = 0; i < coll1.tokenIds.length; i++) {
            if (coll1.tokenIds[i] == _tokenId) {
                isNew = false;
                break;
            }
        }
        require(isNew, "Collection1#addToCollection: TOKEN_ID_ALREADY_FOUND");
        coll1.tokenIds.push(_tokenId);
    }
    ///////////////////// END Collections 1 /////////////////////////////////

} //end contract

