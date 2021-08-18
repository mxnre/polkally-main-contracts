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

contract Market is ContractBase, Category, TransferBase {
    using SafeMath for uint256;

    event NewList(uint256 _id);
    event DeListed(uint256 _id);

    /**
     * initialize contract
     */
    constructor(address storeAddress) {
        initializeDataStore(storeAddress);
    }

    /**
     * list new Market Item
     * @param  _assetContract   - Asset Contract address
     * @param  _tokenId   -  the Id of Token
     * @param  _assetType -  ERC1155 or ERC721
     * @param  _count   -  Total count ERC721 = 1, ERC1155 = multi
     * @param  _price   -  the asking Price
     * @param  _paymentToken   - the token address for payment
     */
    function list(
        uint256           _categoryId,
        address           _assetContract,
        uint256           _tokenId,
        bytes32           _assetType,
        uint256           _count,
        uint256           _price,
        address           _paymentToken
    ) public returns(uint256) {

        require(_price > 0, "Market#list: INVALID_PRICE");

        //lets save new data
        uint256 newItemId = _dataStore.nextMarketItemId();

        PriceInfo memory _priceInfo = PriceInfo({
            paymentToken:    _paymentToken,
            value:           _price
        });

        AuctionData memory _auction = AuctionData({
            isTimeLimted:    false,
            startTime:       0,
            endTime:         0
        });

        _dataStore.saveMarketItem(newItemId, MarketItem({
            id:              newItemId,
            categoryId:      _categoryId,
            bidType:         FIXED_ASSET_TYPE,
            assetType:       _assetType,
            assetContract:   _assetContract,
            tokenId:         _tokenId,
            count:           _count,
            owner:           _msgSender(),
            askingPrice:     _priceInfo,
            auctionData:     _auction,
            isActive:        true,
            createdAt:       block.timestamp,
            updatedAt:       block.timestamp
        }));

        // Transfer Asset To Market Contract.
        transfer(_assetType, _assetContract, _tokenId, _msgSender(), address(this), _count);

        emit NewList(newItemId);

        return newItemId;
    } //end

    /**
     * delist  Item
     * @param  _itemId   - Item Id to delist
     */
    function delist(
        uint256           _itemId
    ) public {

        MarketItem memory item = _dataStore.getMarketItem(_itemId);

        require(item.isActive, "Market#delist: INVALID_ITEM_ID");
		require(item.owner == _msgSender() || msg.sender == owner(), "Market#delist: only owner can delist");

        transfer(item.assetType, item.assetContract, item.tokenId, address(this), _msgSender(), item.count);

		_dataStore.delMarketItem(_itemId);

		emit DeListed(_itemId);
    } //end

}
