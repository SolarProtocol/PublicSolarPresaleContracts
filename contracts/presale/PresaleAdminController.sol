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

import {LibPresale} from "./LibPresale.sol";
import {LibUtils} from "./../LibUtils.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev External controller for LibPresale exposing functions for admin interaction.
 */
contract PresaleAdminController is Initializable {
    function initialize(
        ERC20 investmentToken,
        address vault,
        string memory name_,
        string memory symbol_,
        uint256 startsAt,
        uint256 endsAt,
        uint256 userCap,
        uint256 totalCap,
        uint256 minimalInvestment,
        uint256 step,
        LibPresale.Epoch[] memory epochs
    ) public initializer {
        LibPresale.initialize(
            investmentToken,
            vault,
            name_,
            symbol_,
            startsAt,
            endsAt,
            userCap,
            totalCap,
            minimalInvestment,
            step,
            epochs
        );
    }

    function addEpoch(LibPresale.Epoch memory epoch) external {
        LibUtils.enforceIsContractOwner();

        LibPresale.addEpoch(epoch);
    }

    function updateEpoch(LibPresale.Epoch memory epoch) external {
        LibUtils.enforceIsContractOwner();

        LibPresale.updateEpoch(epoch);
    }

    function setTimestamps(uint256 startsAt, uint256 endsAt) external {
        LibUtils.enforceIsContractOwner();

        LibPresale.setTimestamps(startsAt, endsAt);
    }
}
