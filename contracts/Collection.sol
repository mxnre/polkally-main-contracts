// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./ContractBase.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Collection is  ContractBase {

    using SafeMath for uint256;

    event NewCollection(uint256 _id);
    event UpdateCollection(uint256 _id);


    /**
     * create collection
     * @param  _creator     - the address of collection creator
     * @param  _uri         - the collection URI
     * @param  _categoryId  - the category id of collection
     */
    function newCollection(
        address           _creator,
        string    memory  _uri,
        uint256           _categoryId
    ) public onlyOwner returns(uint256) {
        require(bytes(_uri).length > 0, "Collection#newCollection: INVALID_URI");
        require(_categoryId > 0 && _categoryId <= _dataStore.totalCategories(), "Collection#newCollection: INVALID_CATEGORY_ID");

        uint256 collectionId = _dataStore.nextCollectionId();

        _dataStore.saveCollection(collectionId, Collection({
            id:         collectionId,
            creator:    _creator,
            uri:        _uri,
            categoryId: _categoryId
        }));

        emit NewCollection(collectionId);

        return collectionId;
    }


    /**
     * update collection
     * @param  _id          - the collection id
     * @param  _creator     - the address of collection creator
     * @param  _uri         - the collection URI
     * @param  _categoryId  - the category id of collection
     */
    function updateCollection(
        uint256           _id,
        address           _creator,
        string    memory  _uri,
        uint256           _categoryId
    ) public onlyOwner {

        require(_id > 0 && _id <= _dataStore.totalCollections(), "Collection#updateCollection: INVALID_COLLECTION_ID");

        // get old collection info
        Collection memory oldCollection = _dataStore.getCollection(_id);

        oldCollection.creator         = _creator;
        oldCollection.uri             = _uri;
        oldCollection.categoryId      = _categoryId;

        _dataStore.saveCollection(_id, oldCollection);

        emit UpdateCollection(_id);
    }

    /**
     * getCollectionById - fetch a collection using it id
     * @param _id the collectionId
     */
    function getCollectionById(uint256 _id) public view returns(Collection memory) {
        require(_id > 0 && _id <= _dataStore.totalCollections(), "Collection#getCollectionById: INVALID_COLLECTION_ID");

        Collection memory collection = _dataStore.getCollection(_id);

        return collection;
    }

}
