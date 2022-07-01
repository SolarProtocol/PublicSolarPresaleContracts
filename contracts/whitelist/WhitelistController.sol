// SPDX-License-Identifier: MIT

//////////////////////////////////////////////solarprotocol.io//////////////////////////////////////////
//_____/\\\\\\\\\\\_________/\\\\\_______/\\\__0xFluffyBeard__/\\\\\\\\\_______/\\\\\\\\\_____        //
// ___/\\\/////////\\\_____/\\\///\\\____\/\\\____vbranden___/\\\\\\\\\\\\\___/\\\///////\\\___       //
//  __\//\\\______\///____/\\\/__\///\\\__\/\\\______________/\\\/////////\\\_\/\\\_____\/\\\___      //
//   ___\////\\\__________/\\\______\//\\\_\/\\\_____________\/\\\_______\/\\\_\/\\\\\\\\\\\/____     //
//    ______\////\\\______\/\\\_______\/\\\_\/\\\_____________\/\\\\\\\\\\\\\\\_\/\\\//////\\\____    //
//     _________\////\\\___\//\\\______/\\\__\/\\\_____________\/\\\/////////\\\_\/\\\____\//\\\___   //
//      __/\\\______\//\\\___\///\\\__/\\\____\/\\\_____________\/\\\_______\/\\\_\/\\\_____\//\\\__  //
//       _\///\\\\\\\\\\\/______\///\\\\\/_____\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_\/\\\______\//\\\_ //
//        ___\///////////__________\/////_______\///////////////__\///________\///__\///________\///__//
////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.8.9;

import {IWhitelist} from "./IWhitelist.sol";
import {LibWhitelist} from "./LibWhitelist.sol";
import {LibUtils} from "./../LibUtils.sol";

/**
 * @dev External controller for managing the whitelists.
 */
contract WhitelistController is IWhitelist {
    function isWhitelisted(address account) external view returns (bool) {
        return LibWhitelist.isWhitelisted(account);
    }

    function isWhitelistedIn(address account, uint256[] memory whitelistIds)
        external
        view
        returns (bool)
    {
        return LibWhitelist.isWhitelistedIn(account, whitelistIds);
    }

    function isWhitelistedIn(address account, uint256 whitelistId)
        external
        view
        returns (bool)
    {
        return LibWhitelist.isWhitelistedIn(account, whitelistId);
    }

    function getAccountWhitelist(address account)
        external
        view
        returns (uint256)
    {
        return LibWhitelist.getAccountWhitelist(account);
    }

    function whitelistLength() external view returns (uint256) {
        return LibWhitelist.length();
    }

    function getWhitelitedAccountAt(uint256 index)
        external
        view
        returns (address, uint256)
    {
        return LibWhitelist.at(index);
    }

    function whitelist(address account, uint256 whitelistId) external {
        LibUtils.enforceIsContractOwner();

        LibWhitelist.whitelist(account, whitelistId);
    }

    function whitelist(address[] calldata accounts, uint256 whitelistId)
        external
    {
        LibUtils.enforceIsContractOwner();

        for (uint256 index = 0; index < accounts.length; ++index) {
            LibWhitelist.whitelist(accounts[index], whitelistId);
        }
    }

    function dewhitelist(address account) external {
        LibUtils.enforceIsContractOwner();

        LibWhitelist.dewhitelist(account);
    }

    function dewhitelist(address[] calldata accounts) external {
        LibUtils.enforceIsContractOwner();

        for (uint256 index = 0; index < accounts.length; ++index) {
            LibWhitelist.dewhitelist(accounts[index]);
        }
    }
}
