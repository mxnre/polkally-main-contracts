// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../StructsDef.sol";
import "../Storage/StoreVars.sol";

abstract contract IDataStore is StructsDef, StoreVars {

    function setMaxRoyaltyBps(uint256 _maxRoyaltyBps) virtual public;

    // categories
    function nextCategoryId()  virtual public returns(uint256);
    function getCategory(uint256 _id) virtual public view returns(CategoryInfo memory);
    function saveCategory(uint256 _id, CategoryInfo memory _catInfo)  virtual public;
    function setTotalDisabledCategories(uint256 _value) virtual public;

    // Markets
    function nextMarketItemId()  virtual public returns(uint256);
    function getMarketItem(uint256 _id) virtual public view returns(MarketItem memory);
    function saveMarketItem(uint256 _id, MarketItem memory _marketInfo)  virtual public;
    function delMarketItem(uint256 _id) virtual public;

    // Auction & Bids
    function nextBidId() virtual public returns(uint256);
    function addBid(uint256 _id, Bid memory bid) virtual public;
    function increaseBid(uint256 _id, uint256 bidId, uint256 _amount) virtual public;
    function closeBid(uint256 _bidId) virtual public;
    function getBidFromId(uint256 _bidId) virtual public view returns(Bid memory);
    function getBidIdsForAuction(uint256 _id) virtual public view returns (uint256[] memory);
    function getBidsLengthForAuction(uint256 _id) virtual public view returns(uint256);
    function getUserBidForAuction(uint256 _id, address bidder) virtual public view returns(Bid memory);
    function getWinningBidForAuction(uint256 _id) virtual public view returns(Bid memory);


    // Bid History
    function addUserBidHistory(address _account, uint256 _bidId) virtual public;

    // configs
    function getMainConfigs() virtual public view returns(ConfigsData memory);
    function setConfigsData() virtual public;

    // Collections
    function nextCollectionId() virtual public returns(uint256);
    function getCollection(uint256 _id) virtual public view returns(Collection memory);
    function saveCollection(uint256 _id, Collection memory _collection) virtual public;

    // Collections1
    function nextCollection1Id() virtual public returns(uint256);
    function getCollection1(uint256 _id) virtual public view returns(Collection1 memory);
    function saveCollection1(uint256 _id, Collection1 memory _collection1) virtual public;
    function addToCollection1(uint256 _id, uint256 _tokenId) virtual public;

    //basic  store
    mapping(bytes32 => bool)     public    _boolStore;
    mapping(bytes32 => int256)   public    _intStore;
    mapping(bytes32 => uint256)  public    _uintStore;
    mapping(bytes32 => string)   public    _stringStore;
    mapping(bytes32 => address)  public    _addressStore;
    mapping(bytes32 => bytes)    public    _bytesStore;
    mapping(bytes32 => bytes32)  public    _bytes32Store;


    function setBoolean(bytes32 _k, bool _v) virtual public;
    function setInt(bytes32 _k, int _v) virtual public;
    function setUint(bytes32 _k, uint256 _v) virtual public;
    function setAddress(bytes32 _k, address _v) virtual public;
    function setString(bytes32 _k, string memory _v) virtual public;
    function setBytes(bytes32 _k, bytes memory _v) virtual public;

}
