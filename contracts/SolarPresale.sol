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

import {PresaleController} from "./presale/PresaleController.sol";
import {PresaleGettersController} from "./presale/PresaleGettersController.sol";
import {PresaleAdminController} from "./presale/PresaleAdminController.sol";
import {ERC20Controller} from "./presale/ERC20Controller.sol";
import {PausableController} from "./pausable/PausableController.sol";
import {WhitelistController} from "./whitelist/WhitelistController.sol";
import {LibPausable} from "@solarprotocol/libraries/contracts/security/pausable/LibPausable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Main contract assembling all the controllers.
 *
 * Attention: Initializable is the only contract that does not use the
 * Diamond Storage pattern and MUST be on first possition ALLWAYS!!!
 */
contract SolarPresale is
    Initializable,
    PresaleAdminController,
    PresaleGettersController,
    PresaleController,
    ERC20Controller,
    WhitelistController,
    PausableController
{

}
