// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract StoreCore is Ownable {

   event SetDataWriter(address indexed oldWriter, address indexed newWritter);


   address public dataWriter;

   constructor() {
      dataWriter = msg.sender;
   }

   modifier onlyDataWriter {
      require(msg.sender == dataWriter, "KALLY_DATA_STORE: Only Data Writter is Permitted");
      _;
   }


   //tranfer data writer
   function setDataWriter(address _dataWriter) public onlyOwner {
      address oldWriter = dataWriter;
      dataWriter = _dataWriter;
      emit SetDataWriter(oldWriter,dataWriter);
   }


}
