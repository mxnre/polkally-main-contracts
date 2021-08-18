// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./StoreCore.sol";

contract BasicStore is StoreCore {

   mapping(bytes32 => bool)     public    _boolStore;
   mapping(bytes32 => int256)   public    _intStore;
   mapping(bytes32 => uint256)  public    _uintStore;
   mapping(bytes32 => string)   public    _stringStore;
   mapping(bytes32 => address)  public    _addressStore;
   mapping(bytes32 => bytes)    public    _bytesStore;
   mapping(bytes32 => bytes32)  public    _bytes32Store;


   function setBoolean(bytes32 _k, bool _v) public onlyDataWriter {
      _boolStore[_k] = _v;
   }

   function setInt(bytes32 _k, int _v) public onlyDataWriter {
      _intStore[_k] = _v;
   }

   function setUint(bytes32 _k, uint256 _v) public onlyDataWriter {
      _uintStore[_k] = _v;
   }

   function setAddress(bytes32 _k, address _v) public onlyDataWriter {
      _addressStore[_k] = _v;
   }


   function setString(bytes32 _k, string memory _v) public onlyDataWriter {
      _stringStore[_k] = _v;
   }


   function setBytes(bytes32 _k, bytes memory _v) public onlyDataWriter {
      _bytesStore[_k] = _v;
   }

}
