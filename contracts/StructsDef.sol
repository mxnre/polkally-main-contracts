// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

contract StructsDef {


   /**
    * category definition
    */
    struct CategoryInfo {
        uint256                   id;
        uint256                   parentId;
        string                    name;
        string                    ipfsHash;
        bool                      status;
        uint256                   createdAt;
        uint256                   updatedAt;
    }

    ///////////////// CONFIG STRUCT ////////////////

    struct FeeConfig {
        uint256  maxRoyaltyFeeBps;
        uint256  mintFeeBps;
        uint256  sellTxFeeBps; // Transaction fee, for sellers
        uint256  buyTxFeeBps; // Transaction fee for buyers
        uint256  listingFeeBps; // Fee for listing into the marketplace
    }

    struct ConfigsData {
        FeeConfig _feeConfig;
    }

    ///////////////////// END CONFIG STRUCT /////////////

    struct AuctionData {
        bool                      isTimeLimted;
        uint256                   startTime;
        uint256                   endTime;
    }

    struct PriceInfo {
        address                   paymentToken;
        uint256                   value;
    }

    struct MarketItem {
        uint256                   id;
        uint256                   categoryId;
        bytes32                   bidType;
        bytes32                   assetType;
        address                   assetContract;
        uint256                   tokenId;
        uint256                   count;
        address                   owner;
        PriceInfo                 askingPrice;
        AuctionData               auctionData;
        bool                      isActive;
        uint256                   createdAt;
        uint256                   updatedAt;
    }


    struct Bid {
        uint256                   id;
        uint256                   marketId;
        address                   bidder;
        address                   currency;
        uint256                   value;
        bool                      isActive;
        uint256                   createdAt;
    }

    struct Collection {
        uint256 id;
        address creator;
        string uri;
        uint256 categoryId;
    }

    struct Collection1 {
        uint256 id;
        uint256 categoryId;
        uint256 royaltyBps;
        address creator;
        string uri;
        address assetContract;
        address[] paymentTokens;
        uint256[] tokenIds;
        bytes32 assetType;
    }

}
