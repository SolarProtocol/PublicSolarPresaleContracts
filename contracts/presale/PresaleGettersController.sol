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

/**
 * @dev External controller for LibPresale exposing functions for regular interaction.
 */
contract PresaleGettersController {
    struct CurrentEpochResponse {
        LibPresale.Epoch epoch;
        uint256 endsAt;
    }

    function getCurrentEpoch()
        external
        view
        returns (CurrentEpochResponse memory)
    {
        (LibPresale.Epoch memory epoch, uint256 endsAt) = LibPresale
            .getCurrentEpoch();
        return CurrentEpochResponse(epoch, endsAt);
    }

    function getEpoch(uint256 id)
        external
        view
        returns (LibPresale.Epoch memory)
    {
        return LibPresale.getEpoch(id);
    }

    function getEpochsLength() external view returns (uint256) {
        return LibPresale.getEpochsLength();
    }

    function getInvestmentTokenAddress() external view returns (address) {
        return LibPresale.getInvestmentTokenAddress();
    }

    function getVaultAddress() external view returns (address) {
        return LibPresale.getVaultAddress();
    }

    function getStartsAt() external view returns (uint256) {
        return LibPresale.getStartsAt();
    }

    function getEndsAt() external view returns (uint256) {
        return LibPresale.getEndsAt();
    }

    function getUserCap() external view returns (uint256) {
        return LibPresale.getUserCap();
    }

    function getTotalCap() external view returns (uint256) {
        return LibPresale.getTotalCap();
    }

    function getMinimalBalance() external view returns (uint256) {
        return LibPresale.getMinimalBalance();
    }

    function getStep() external view returns (uint256) {
        return LibPresale.getStep();
    }

    function getTotalInvested() external view returns (uint256) {
        return LibPresale.getTotalInvested();
    }

    function getTotalInvestedInEpoch(uint256 epochId)
        external
        view
        returns (uint256)
    {
        return LibPresale.getTotalInvestedInEpoch(epochId);
    }

    function getTotalIssued() external view returns (uint256) {
        return LibPresale.getTotalIssued();
    }

    function getInvestorsLength() external view returns (uint256) {
        return LibPresale.getInvestorsLength();
    }

    function getInvestorAt(uint256 index) external view returns (address) {
        return LibPresale.getInvestorAt(index);
    }

    function getInvestorTotalInvested(address investor)
        external
        view
        returns (uint256)
    {
        return LibPresale.getInvestorTotalInvested(investor);
    }

    function getInvestorTotalInvestedInEpoch(address investor, uint256 epochId)
        external
        view
        returns (uint256)
    {
        return LibPresale.getInvestorTotalInvestedInEpoch(investor, epochId);
    }

    function getBlockTimesatamp() external view returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp;
    }

    function hasStarted() external view returns (bool) {
        return LibPresale.hasStarted();
    }

    function hasEnded() external view returns (bool) {
        return LibPresale.hasEnded();
    }
}
