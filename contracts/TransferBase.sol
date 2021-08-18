// SPDX-License-Identifier: MIT

/**
 * Polkally (https://polkally.com)
 * @author Polkally <hello@polkally.com>
 */

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./ContractBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract TransferBase is  Ownable, ContractBase {

    //event
    event Transfer(bytes32 assetType, address token, uint256 tokenId, address from, address to, uint256 value);

    function transfer(
        bytes32 assetType,
        address token,
        uint256 tokenId,
        address from,
        address to,
        uint256 value
    ) internal {
        if (assetType == ETH_ASSET_TYPE) {
            (bool success, ) = to.call{ value: value }("");
            require(success, "TransferBase#transfer: ETH transfer failed");
        } else if (assetType == ERC20_ASSET_TYPE) {
            require(IERC20(token).transferFrom(from, to, value), "TransferBase#transfer: ERC20 transfer failed");
        } else if (assetType == ERC721_ASSET_TYPE) {
            require(value == 1, "TransferBase#transfer: erc721 value error");
            IERC721(token).safeTransferFrom(from, to, tokenId);
        } else if (assetType == ERC1155_ASSET_TYPE) {
            IERC1155(token).safeTransferFrom(from, to, tokenId, value, "");
        } else {
            revert("TransferBase#transfer: INVALID ASSET TYPE");
        }
        emit Transfer(assetType, token, tokenId, from, to, value);
    }

}
