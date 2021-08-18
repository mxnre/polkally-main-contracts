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

    event AdduserBidHistory(address indexed _account, uint256 _bidId);

    /**
     * @dev After user has bidded successfully, lets save the bid history
     * @param _account the account to save the bid history id
     * @param _bidId the bid id
     */
    function adduserBidHistory(address _account, uint256 _bidId) internal {
        _dataStore.addUserBidHistory(_account, _bidId);
        emit AdduserBidHistory(_account, _bidId);
    }

}
