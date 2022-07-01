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

import {LibUtils} from "./../LibUtils.sol";
import {LibWhitelist} from "./../whitelist/LibWhitelist.sol";
import {LibContext} from "@solarprotocol/libraries/contracts/utils/LibContext.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @dev Main presale library handling the investment and redeeming of the rewards.
 */
library LibPresale {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    /**
     * @dev Struct with settings of a single epoch.
     */
    struct Epoch {
        uint256 id;
        // Duration of the epoch.
        uint256 duration;
        // Price in that epoch.
        uint256 price;
        // Maximum amount a user can buy during this epoch.
        uint256 epochUserCap;
        // Maximum amount a user can buy in total by this moment.
        uint256 userCap;
        // Maximum amount that can be purchased by all users during this epoch.
        uint256 epochTotalCap;
        // Maximum amount that can be purchased by all users in total by this moment.
        uint256 totalCap;
        // Array with ids of whitelist eligable for this epoch.
        uint256[] whitelistIds;
    }

    /**
     * @dev Information about an investor.
     */
    struct InvestorInfo {
        // Mapping of epoch to invested amount
        mapping(uint256 => uint256) investedAmounts;
        // Mapping of epoch to issued amount
        mapping(uint256 => uint256) issuedAmounts;
        // Total invested across all epochs
        uint256 totalInvested;
        // Balance of the internal reward token.
        uint256 balance;
    }

    struct Storage {
        // Name to use in the ERC20 controller
        string name;
        // Symbol to use in the ERC20 controller
        string symbol;
        // Address where the investment token will be deposited.
        address vault;
        // Investment token.
        ERC20 investmentToken;
        uint256 investmentTokenDecimals;
        // Unix timestamp when the presale should start.
        uint256 startsAt;
        // Unix timestamp when the presale should end.
        uint256 endsAt;
        // Maximum amount a user can purchase.
        uint256 userCap;
        // Maximum amount that can be purchased by all users during the presale.
        uint256 totalCap;
        // Minimal amount a user must purchase to participate in the presale.
        uint256 minimalBalance;
        // Step between purchase quants.
        // Example with a step of 5 and userCap of 30: 5, 10, 15, 20, 25, 30.
        // Default: Disabled (0).
        uint256 step;
        // Sum of all investments done during presale, nominated in `investmentToken`;
        uint256 totalInvested;
        // Sum of all presale tokens issued to investors.
        uint256 totalIssued;
        // Current total supply (sum of all balances).
        uint256 totalSupply;
        // Length of the epochs mapping. Used to iterate through the mapping.
        uint256 epochsLength;
        // Mapping with all the epochs and their settings.
        mapping(uint256 => Epoch) epochs;
        // Mapping the addresses to infestor profiles
        mapping(address => InvestorInfo) investorInfoMap;
        // Mapping of epoch to amount invested by all users
        mapping(uint256 => uint256) investedAmounts;
        // Mapping of epoch to amount issued by all users
        mapping(uint256 => uint256) issuedAmounts;
        // List of all addresses who made an investment, to use in iterations.
        address[] investors;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("solarprotocol.contracts.presale.LibSolarPresale");

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

    /**
     * @dev Emitted when a user makes an investment.
     */
    event Invested(
        address indexed account,
        uint256 epochId,
        uint256 amount,
        uint256 issued
    );

    /**
     * @dev ERC20 transfer event. Emitted when issued after investment.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    error AlreadyInitialized();
    error EmptyEpochs();
    error EpochNotFound(uint256 id);
    error PresaleNotStarted();
    error PresaleEnded();
    error OutOfEpochs();
    error TotalCapReached();
    error UserCapReached();
    error EpochCapReached();
    error InvalidStep();
    error MinimalBalance();

    function initialize(
        ERC20 investmentToken,
        address vault,
        string memory name,
        string memory symbol,
        uint256 startsAt,
        uint256 endsAt,
        uint256 userCap,
        uint256 totalCap,
        uint256 minimalBalance,
        uint256 step,
        Epoch[] memory epochs
    ) internal {
        Storage storage s = _storage();

        if (address(s.investmentToken) != address(0)) {
            revert AlreadyInitialized();
        }

        LibUtils.validateERC20(address(investmentToken));

        if (epochs.length == 0) {
            revert EmptyEpochs();
        }

        s.investmentToken = investmentToken;
        s.investmentTokenDecimals = investmentToken.decimals();
        s.vault = vault;
        s.name = name;
        s.symbol = symbol;
        s.userCap = userCap;
        s.totalCap = totalCap;
        s.minimalBalance = minimalBalance;
        s.step = step;

        setTimestamps(startsAt, endsAt);

        addEpochs(epochs);
    }

    function invest(uint256 amount) internal {
        Storage storage s = _storage();

        address investorAddress = LibContext.msgSender();

        // solhint-disable-next-line not-rely-on-time
        if (!hasStarted()) {
            revert PresaleNotStarted();
        }

        // solhint-disable-next-line not-rely-on-time
        if (hasEnded()) {
            revert PresaleEnded();
        }

        InvestorInfo storage investor = s.investorInfoMap[investorAddress];

        (Epoch storage currentEpoch, ) = getCurrentEpoch();

        if (currentEpoch.whitelistIds.length > 0) {
            LibWhitelist.enforceWhitelisted(currentEpoch.whitelistIds);
        }

        if (s.totalInvested == 0) {
            s.investors.push(investorAddress);
        }

        uint256 issued = (amount /
            currentEpoch.price /
            (10**s.investmentTokenDecimals)) * 10**18;
        s.totalInvested += amount;
        s.investedAmounts[currentEpoch.id] += amount;
        investor.totalInvested += amount;
        investor.investedAmounts[currentEpoch.id] += amount;

        s.totalIssued += issued;
        s.totalSupply += issued;
        s.issuedAmounts[currentEpoch.id] += issued;
        investor.issuedAmounts[currentEpoch.id] += issued;
        investor.balance += issued;

        _checkLimits(investor, currentEpoch, issued);

        s.investmentToken.safeTransferFrom(
            LibContext.msgSender(),
            _getVault(),
            amount
        );

        emit Invested(investorAddress, currentEpoch.id, amount, issued);
        emit Transfer(address(0), LibContext.msgSender(), issued);
    }

    function setTimestamps(uint256 startsAt, uint256 endsAt) internal {
        _storage().startsAt = startsAt;
        _storage().endsAt = endsAt;
    }

    function getCurrentEpoch()
        internal
        view
        returns (Epoch storage, uint256 endsAt)
    {
        Storage storage s = _storage();

        Epoch storage epoch;
        endsAt = s.startsAt;

        for (uint256 index = 1; index <= s.epochsLength; ++index) {
            epoch = s.epochs[index];

            endsAt += epoch.duration;

            // solhint-disable-next-line not-rely-on-time
            if (endsAt > block.timestamp) {
                return (epoch, endsAt);
            }
        }

        revert OutOfEpochs();
    }

    function addEpochs(Epoch[] memory epochs) internal {
        for (uint256 index = 0; index < epochs.length; ++index) {
            addEpoch(epochs[index]);
        }
    }

    function addEpoch(Epoch memory epoch) internal {
        uint256 epochsLength = _storage().epochsLength;
        epochsLength++;
        epoch.id = epochsLength;
        _storage().epochs[epoch.id] = epoch;
        _storage().epochsLength = epochsLength;
    }

    function updateEpoch(Epoch memory epoch) internal {
        if (_storage().epochs[epoch.id].id == 0) {
            revert EpochNotFound(epoch.id);
        }
        _storage().epochs[epoch.id] = epoch;
    }

    function getEpoch(uint256 id) internal view returns (Epoch memory) {
        return _storage().epochs[id];
    }

    function getEpochsLength() internal view returns (uint256) {
        return _storage().epochsLength;
    }

    function getName() internal view returns (string memory) {
        return _storage().name;
    }

    function getSymbol() internal view returns (string memory) {
        return _storage().symbol;
    }

    function getInvestmentTokenAddress() internal view returns (address) {
        return address(_storage().investmentToken);
    }

    function getVaultAddress() internal view returns (address) {
        return _storage().vault;
    }

    function getStartsAt() internal view returns (uint256) {
        return _storage().startsAt;
    }

    function getEndsAt() internal view returns (uint256) {
        return _storage().endsAt;
    }

    function getUserCap() internal view returns (uint256) {
        return _storage().userCap;
    }

    function getTotalCap() internal view returns (uint256) {
        return _storage().totalCap;
    }

    function getMinimalBalance() internal view returns (uint256) {
        return _storage().minimalBalance;
    }

    function getStep() internal view returns (uint256) {
        return _storage().step;
    }

    function getTotalInvested() internal view returns (uint256) {
        return _storage().totalInvested;
    }

    function getTotalInvestedInEpoch(uint256 epochId)
        internal
        view
        returns (uint256)
    {
        return _storage().investedAmounts[epochId];
    }

    function getTotalIssued() internal view returns (uint256) {
        return _storage().totalIssued;
    }

    function getTotalSupply() internal view returns (uint256) {
        return _storage().totalSupply;
    }

    function getInvestorsLength() internal view returns (uint256) {
        return _storage().investors.length;
    }

    function getInvestorAt(uint256 index) internal view returns (address) {
        return _storage().investors[index];
    }

    function getInvestorBalance(address investor)
        internal
        view
        returns (uint256)
    {
        return _storage().investorInfoMap[investor].balance;
    }

    function getInvestorTotalInvested(address investor)
        internal
        view
        returns (uint256)
    {
        return _storage().investorInfoMap[investor].totalInvested;
    }

    function getInvestorTotalInvestedInEpoch(address investor, uint256 epochId)
        internal
        view
        returns (uint256)
    {
        return _storage().investorInfoMap[investor].investedAmounts[epochId];
    }

    function hasStarted() internal view returns (bool) {
        Storage storage s = _storage();

        return block.timestamp > s.startsAt;
    }

    function hasEnded() internal view returns (bool) {
        Storage storage s = _storage();

        return block.timestamp > s.endsAt;
    }

    function _getVault() private view returns (address) {
        Storage storage s = _storage();

        if (s.vault == address(0)) {
            return address(this);
        }

        return s.vault;
    }

    function _checkLimits(
        InvestorInfo storage investor,
        Epoch storage currentEpoch,
        uint256 issued
    ) private view {
        Storage storage s = _storage();

        if (s.totalIssued > s.totalCap) {
            revert TotalCapReached();
        }

        if (
            currentEpoch.totalCap > 0 && s.totalIssued > currentEpoch.totalCap
        ) {
            revert TotalCapReached();
        }

        if (s.userCap > 0 && investor.balance > s.userCap) {
            revert UserCapReached();
        }

        if (
            (currentEpoch.userCap > 0 &&
                investor.balance > currentEpoch.userCap)
        ) {
            revert UserCapReached();
        }

        if (
            (currentEpoch.epochTotalCap > 0 &&
                s.issuedAmounts[currentEpoch.id] > currentEpoch.epochTotalCap)
        ) {
            revert EpochCapReached();
        }

        if (
            (currentEpoch.epochUserCap > 0 &&
                investor.issuedAmounts[currentEpoch.id] >
                currentEpoch.epochUserCap)
        ) {
            revert EpochCapReached();
        }

        if (issued < 1) {
            revert MinimalBalance();
        }

        if (s.minimalBalance > 0 && s.minimalBalance > investor.balance) {
            revert MinimalBalance();
        }

        if (s.step > 0 && investor.balance.mod(s.step) != 0) {
            revert InvalidStep();
        }
    }
}
