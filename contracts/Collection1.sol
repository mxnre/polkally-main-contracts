// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./ContractBase.sol";
import "./Market.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Collection1 is  ContractBase {

    using SafeMath for uint256;

    Market public market;

    function addToCollection(
        uint256 _collId,
        uint256 _tokenId,
        uint256 _count,
        uint256 _price,
        address _paymentToken
    ) public {
        require(_collId <= _dataStore.totalCollections1(), "Collection1#addToCollection: INVALID_COLLECTION_ID");
        Collection1 memory coll1 = _dataStore.getCollection1(_collId);

        // TODO check if `_tokenId` exists in asset contract

        _dataStore.addToCollection1(_collId, _tokenId);

        // check if `_paymentToken` is found in collection payment tokens array

        market.list(coll1.categoryId, coll1.assetContract, _tokenId, coll1.assetType, _count, _price, _paymentToken);
    }


}
