// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Shiro <shiro@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./CustomStore.sol";
import "./StoreCore.sol";

contract DataStore is StoreCore, CustomStore {}
