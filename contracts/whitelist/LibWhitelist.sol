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
import {LibContext} from "@solarprotocol/libraries/contracts/utils/LibContext.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

library LibWhitelist {
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    struct Storage {
        // Mapping from user account to whitelist id.
        EnumerableMap.AddressToUintMap whitelist;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("solarprotocol.contracts.presale.LibWhitelists");

    /**
     * @dev Returns the storage.
     */
    function _storage() private pure returns (Storage storage s) {
        bytes32 slot = STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := slot
        }
    }

    event Whitelisted(address indexed account, uint256 whitelistId);
    event Dewhitelisted(address indexed account, uint256 whitelistId);

    function enforceWhitelisted(uint256 whitelistId) internal view {
        enforceWhitelisted(LibContext.msgSender(), whitelistId);
    }

    function enforceWhitelisted(address account, uint256 whitelistId)
        internal
        view
    {
        if (!isWhitelistedIn(account, whitelistId)) {
            revert IWhitelist.AccountNotInWhitelist(account, whitelistId);
        }
    }

    function enforceWhitelisted(uint256[] memory whitelistIds) internal view {
        enforceWhitelisted(LibContext.msgSender(), whitelistIds);
    }

    function enforceWhitelisted(address account, uint256[] memory whitelistIds)
        internal
        view
    {
        if (!isWhitelistedIn(account, whitelistIds)) {
            revert IWhitelist.AccountNotInAnyWhitelist(account, whitelistIds);
        }
    }

    function isWhitelisted(address account) internal view returns (bool) {
        return _storage().whitelist.contains(account);
    }

    function isWhitelistedIn(address account, uint256[] memory whitelistIds)
        internal
        view
        returns (bool)
    {
        for (uint256 index = 0; index < whitelistIds.length; ++index) {
            if (isWhitelistedIn(account, whitelistIds[index])) {
                return true;
            }
        }

        return false;
    }

    function isWhitelistedIn(address account, uint256 whitelistId)
        internal
        view
        returns (bool)
    {
        (bool success, uint256 currentWhitelistId) = _storage()
            .whitelist
            .tryGet(account);

        return success && (currentWhitelistId == whitelistId);
    }

    function getAccountWhitelist(address account)
        internal
        view
        returns (uint256)
    {
        return _storage().whitelist.get(account);
    }

    function length() internal view returns (uint256) {
        return _storage().whitelist.length();
    }

    function at(uint256 index) internal view returns (address, uint256) {
        return _storage().whitelist.at(index);
    }

    function whitelist(address account, uint256 whitelistId) internal {
        if (whitelistId == 0) {
            revert IWhitelist.ZeroWhitelistId();
        }

        // solhint-disable-next-line no-unused-vars
        (bool success, uint256 currentWhitelistId) = _storage()
            .whitelist
            .tryGet(account);

        if (whitelistId != currentWhitelistId) {
            _storage().whitelist.set(account, whitelistId);

            if (currentWhitelistId > 0) {
                emit Dewhitelisted(account, whitelistId);
            }

            emit Whitelisted(account, whitelistId);
        }
    }

    function dewhitelist(address account) internal {
        // solhint-disable-next-line no-unused-vars
        (bool success, uint256 whitelistId) = _storage().whitelist.tryGet(
            account
        );
        if (whitelistId > 0) {
            _storage().whitelist.remove(account);

            emit Dewhitelisted(account, whitelistId);
        }
    }
}
