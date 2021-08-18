// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./ContractBase.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Category is  ContractBase {

    using SafeMath for uint256;

    event NewCategory(uint256 _id);
    event UpdateCategory(uint256 _id);


    /**
     * create category
     * @param  _name     - the name of the category
     * @param  _parentId -  the category Parent, set 0 for base or parentless categoryId
     * @param  _ipfsHash -  the ipfs hash for the category meta data
     * @param  _status   - the status of the newely built category, true for enabled category, false for disabled category
     */
    function newCategory(
        string   memory   _name,
        uint256           _parentId,
        string   memory   _ipfsHash,
       // bytes32[] memory   _tags,
        bool              _status
    ) public onlyOwner returns(uint256) {

        //if the parentId > 0, then lets verify if it exists and enabled
        if(_parentId > 0){
            CategoryInfo memory catParentInfo = _dataStore.getCategory(_parentId);
            require(catParentInfo.status, "Category#newCategory: INVALID_CATEGORY_PARENT");
        }

        //lets save new data
        uint256 categoryId = _dataStore.nextCategoryId();

        _dataStore.saveCategory(categoryId, CategoryInfo({
            id:         categoryId,
            name:       _name,
            parentId:   _parentId,
            ipfsHash:   _ipfsHash,
            status:     _status,
            createdAt:  block.timestamp,
            updatedAt:  block.timestamp
        }));


        // if category is disabled by default, add it to disabled category count
        if(!_status) {
            _dataStore.setTotalDisabledCategories(_dataStore.totalDisabledCategories().add(1));
        }

        emit NewCategory(categoryId);

        return categoryId;
    } //end fun


    /**
     * updateCategory - updates a category
     * @param  _id       -  he category id
     * @param  _name     -  the name of the category
     * @param  _parentId -  the category Parent, set 0 for base or parentless categoryId
     * @param  _ipfsHash -  the ipfs hash for the category meta data
     * @param  _status   -  the status of the newely built category, true for enabled category, false for disabled category
     */
    function updateCategory(
        uint256           _id,
        string   memory   _name,
        uint256           _parentId,
        string   memory   _ipfsHash,
        bool              _status
    ) public onlyOwner {

        require(_id > 0 && _id <= _dataStore.totalDisabledCategories(), "Category#updateCategory: INVALID_CATEGORY_ID");

        if(_parentId > 0){
            CategoryInfo memory catParentInfo = _dataStore.getCategory(_parentId);
            require(catParentInfo.status, "Category#newCategory: INVALID_CATEGORY_PARENT");
        }

        // get old category info
        CategoryInfo memory oldCatInfo = _dataStore.getCategory(_id);

        // if old category info was disabled
        if(!_status) {

            //lets check if new category is now enabled
            if(_status && _dataStore.totalDisabledCategories() > 0) {
                _dataStore.setTotalDisabledCategories(_dataStore.totalDisabledCategories().sub(1));
            }

        } else {

            // if the old category was active, lets check if it has been disabled
            if(!_status) {
                _dataStore.setTotalDisabledCategories(_dataStore.totalDisabledCategories().add(1));
            }
        } //end keep track of disabled categories

        oldCatInfo.name         = _name;
        oldCatInfo.parentId     = _parentId;
        oldCatInfo.ipfsHash     = _ipfsHash;
        oldCatInfo.status       = _status;
        oldCatInfo.updatedAt    = block.timestamp;

        _dataStore.saveCategory(_id, oldCatInfo);

        emit UpdateCategory(_id);
    }

    /**
     * getCategoryById - fetch a category using it id
     * @param _id the categoryId
     */
    function getCategoryById(uint256 _id) public view returns(CategoryInfo memory) {
        require(_id > 0, "Category#getCategoryById: INVALID_CATEGORY_ID");

        CategoryInfo memory catData = _dataStore.getCategory(_id);

        require(catData.status,"Category#getCategoryById: CATEGORY_DISABLED");

        return catData;
    }


    /**
     * getParentCategories
     */
    function _getCategories(uint256 parentId, bool onlyEnabled) private view returns(CategoryInfo[] memory) {

        uint256 totalCats =  _dataStore.totalCategories().add(1);

        CategoryInfo[] memory categoryDataArray = new CategoryInfo[] (totalCats);

        for(uint256 i = 1; i <= totalCats; i++) {

            CategoryInfo memory catData = _dataStore.getCategory(i);

            // lets check for a valid category
            if(catData.createdAt == 0) continue;

            if(onlyEnabled && !catData.status) continue;

            if(catData.parentId == parentId) categoryDataArray[i] = catData;
        }

        return categoryDataArray;
    } //ed total cats

    /**
     * get parent categories
     */
    function getParentCategories()  public view returns(CategoryInfo[] memory) {
        return _getCategories(0, true);
    }

    /**
     * get category children
     * @param _id the id of the category which we need the sub categories
     */
    function getSubCategories(uint256 _id) public view returns(CategoryInfo[] memory) {
        return _getCategories(_id, true);
    }

    /////////////// ADMIN FUNCTIONS ////////////////
     /**
     * get parent categories
     */
    function adminFetchParentCategories()  public view onlyOwner returns(CategoryInfo[] memory) {
        return _getCategories(0, false);
    }

    /**
     * get category children
     * @param _id the id of the category which we need the sub categories
     */
    function adminFetchSubCategories(uint256 _id) public view onlyOwner returns(CategoryInfo[] memory) {
        return _getCategories(_id, false);
    }

    ///////////// END ADMIN FUNCTIONS /////////////////

    /**
     * get Categories
     *
    function getCategories(
        uint256 fromId,
        uint256 dataPerPage,
        bytes32 searchKeyword
    ) public view returns (Category[] memory) {

        uint256 totalCategories =  _dataStore.totalCategories();

        uint256 totalActiveCategories = totalCategories.sub(_dataStore.totalDisabledCategories(), "Category#getCategories: totalActiveCategories sub error");

        if(totalActiveCategories == 0) {
            totalActiveCategories = 1;
        }

        Category[] memory categoryDataArray = new Category[] (totalActiveCategories);

        uint256 cursor = fromId;
        uint256 counter;

        while(true) {

            Category memory catData = _dataStore.getCategory(cursor);

            if(!catData.status) continue;

            // lets check if we had search
            if(searchKeyword != ""){

                for(uint256 ti = 0; ti < catData.tags.length; ti++){
                    if(searchKeyword == catData.tags[ti]){
                        categoryDataArray[counter++] = catData;
                    }
                }

                return categoryDataArray;
            } //endd if we have search


            categoryDataArray[counter++] = catData;

            if(counter >= (dataPerPage - 1) || cursor >= totalCategories) break;

            cursor++;
        }

        return categoryDataArray;
    }//end get categories
    */



}
