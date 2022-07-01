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

interface IWhitelist {
    error ZeroWhitelistId();
    error AccountNotInWhitelist(address account, uint256 whitelistId);
    error AccountNotInAnyWhitelist(address account, uint256[] whitelistIds);

    event Whitelisted(address indexed account, uint256 whitelistId);
    event Dewhitelisted(address indexed account, uint256 whitelistId);

    function isWhitelisted(address account) external view returns (bool);

    function isWhitelistedIn(address account, uint256[] memory whitelistIds)
        external
        view
        returns (bool);

    function isWhitelistedIn(address account, uint256 whitelistId)
        external
        view
        returns (bool);

    function getAccountWhitelist(address account)
        external
        view
        returns (uint256);

    function whitelistLength() external view returns (uint256);

    function getWhitelitedAccountAt(uint256 index)
        external
        view
        returns (address, uint256);
}
