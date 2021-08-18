// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../StructsDef.sol";


contract StoreVars {

    ///////////////////////// PUBLIC MAPS //////////////////////

    mapping(address => uint256[]) _userBidHistory;
    mapping (address => uint256[]) _userBuyHistory;
    mapping(address => uint256[]) _userSellHistory;

    /////////////////////// END PUBLIC MAPS ///////////////////

    // initialized
    bool    public  initialized;

    // total categories
    uint256  public totalCategories;
    uint256  public totalDisabledCategories;


    // total Market Items
    uint256  public totalMarketItems;

    // total Bid Items
    uint256  public totalBids;

    // total collections
    uint256  public totalCollections;

    // total collections 1
    uint256  public totalCollections1;
}
