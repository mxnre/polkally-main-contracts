// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./ContractBase.sol";
import "./Category.sol";

contract Factory is ContractBase, Category {

   //config
    StructsDef.ConfigsData private  _initialConfig = StructsDef.ConfigsData({

       // dappToken: ,

        // Fee config structure
        _feeConfig: StructsDef.FeeConfig({

            // the maximum royalty a user can set or an asset in basis point system
            maxRoyaltyFeeBps:  6000,  /// 6000 => 60%

            // minting fee in basis point system, example: 1% => 100
            mintFeeBps: 100,  // 100 => 1%

            // the fee applied to every asset sold, this will be billed the asset owner
            sellTxFeeBps:  500,  // 500 => 5%

            //fee in basis point, this will charged to buyers
            buyTxFeeBps:  0,

            // listing fee in KALLY
            listingFeeBps:  0 // Fee for listing into the marketplace
        })


    });

    /**
     * initialize contract
     */
    constructor(address storeAddress) {
        initializeDataStore(storeAddress);
    }
}
