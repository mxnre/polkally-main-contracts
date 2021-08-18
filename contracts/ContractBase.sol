// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./StructsDef.sol";
import "./interfaces/IDataStore.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractBase is  Ownable, StructsDef {

    /**
     * Asset Types
     */
    bytes32 constant public ETH_ASSET_TYPE = bytes32(keccak256("ETH"));
    bytes32 constant public ERC20_ASSET_TYPE = bytes32(keccak256("ERC20"));
    bytes32 constant public ERC721_ASSET_TYPE = bytes32(keccak256("ERC721"));
    bytes32 constant public ERC1155_ASSET_TYPE = bytes32(keccak256("ERC1155"));


    /**
     * Bid Types
     */
    bytes32 constant public FIXED_ASSET_TYPE = bytes32(keccak256("FixedPrice"));
    bytes32 constant public TIMED_ASSET_TYPE = bytes32(keccak256("TimedAuction"));
    bytes32 constant public OPENBID_ASSET_TYPE = bytes32(keccak256("OpenBid"));

    // datastore
    IDataStore public _dataStore;


    // old config data , a little backup
    ConfigsData public _oldConfigData;

    /**
     * initialize the data store
     * @param dataStoreAddress the external datastore address
     */
    function initializeDataStore(address dataStoreAddress) internal {
        _dataStore = IDataStore(dataStoreAddress);
    }


    /**
     * get all config data
     */
    function getConfigs() public view returns (ConfigsData memory) {
        return _dataStore.getMainConfigs();
    }

    function getFeeConfig() public view returns (FeeConfig memory) {
        return _dataStore.getMainConfigs()._feeConfig;
    }

    /**
     * set config
     * @param _configData new config data
     */
    function setConfig(ConfigsData memory _configData) public onlyOwner {

        //lets do backup first
        _oldConfigData = getConfigs();

        // lets now update
        _dataStore.setConfigsData();
    }


}
