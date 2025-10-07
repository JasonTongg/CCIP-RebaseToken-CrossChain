// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/*
 * @title RebaseToken
 * @author Jason Tong
 * @notice This is a cross-chain rebase token that incentivices users to deposit into a vault and gain interest in rewards
 * @notice The ubterest rate in the smart contract can only decrease
 * @notice Each user will have thier own interest rate that is the global interest rate at the time of depositing
 */
contract RebaseToken is ERC20, Ownable, AccessControl {
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate);

    uint256 private constant PRECISION_FACTOR = 1e18;
    bytes32 private constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE");
    mapping(address => uint256) private s_userInterestRate;
    mapping(address => uint256) private s_userLastUpdatedTimestamp;
    uint256 private s_interestRate = 5e10;

    event InterestRateSet(uint256 newInterestRate);

    constructor() ERC20("Rebase Token", "RBT") Ownable(msg.sender) {}

    function grantMintAndBurnRole(address _account) external onlyOwner {
        _grantRole(MINT_AND_BURN_ROLE, _account);
    }

    /*
     * @notice Set the interest rate in the contract
     * @param _newInterestRate The new interest rate to set
     * @dev The interest rate can only decrease
     */
    function setInterestRate(uint256 _newInterestRate) external onlyOwner {
        //Set the interest rate
        if (_newInterestRate >= s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
        }
        s_interestRate = _newInterestRate;
        emit InterestRateSet(_newInterestRate);
    }

    /*
     *
     * @notice Get the principle balance of a user. This is the number of tokens that have currently been minted to the user, not including any interest that has accrued since the last time the user interacted wth the protocol
     * @param _user The user to get the principle balance for
     * @return The principle balance of the user
     */
    function principalBalanceOf(address _user) external view returns (uint256) {
        return super.balanceOf(_user);
    }

    /*
     * @notice Mint the user tokens when they deposit into the vault
     * @param _to The address to mint the tokens to
     * @param _amount The amount of tokens to mint
     */
    function mint(address _to, uint256 _amount, uint256 _userInterestRate) public onlyRole(MINT_AND_BURN_ROLE) {
        _mintAccruedInterest(_to);
        s_userInterestRate[_to] = _userInterestRate;
        _mint(_to, _amount);
    }

    /*
     * @notice Burn The user tokens when they withdraw from the vault
     * @param _from The user to burn the tokens from
     * @param _amount The amount of tokens to burn
     */
    function burn(address _from, uint256 _amount) public onlyRole(MINT_AND_BURN_ROLE) {
        _mintAccruedInterest(_from);
        _burn(_from, _amount);
    }

    /*
     * Calculate the balance for the user including the interest that has accumulated since the last update
     * (principle balance) + some interest that has accrued
     * @param _user The user to calculate the balance for
     * @return The balance for the user including the interest that has accumulated since the last update
     */
    function balanceOf(address _user) public view override returns (uint256) {
        //get the current principle balance of the user (the number of tokens that have actually been minted to the user)
        //multiply the principle balance by the interest taht has accumulated in the time since the balance was last updated
        //return the principle balance + the interest;

        uint256 currentPrincipalBalance = super.balanceOf(_user);
        if (currentPrincipalBalance == 0) {
            return 0;
        }
        
        return (currentPrincipalBalance * _calculateUserAccumulatedInterestSinceLastUpdate(_user)) / PRECISION_FACTOR;
    }

    /*
     * @notice Transfer tokens from msg.sender/caller to another
     * @param _recipient The user to receive the tokens from _sender
     * @param _amount The amount of token to transfer
     * @return True if the transfer was successful
     */
    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
        if (_amount == type(uint256).max) {
            _amount = balanceOf(msg.sender);
        }

        _mintAccruedInterest(msg.sender);
        _mintAccruedInterest(_recipient);

        if (balanceOf(_recipient) == 0) {
            s_userInterestRate[_recipient] = s_userInterestRate[msg.sender];
        }
        return super.transfer(_recipient, _amount);
    }

    /*
     * @notice Transfer tokens from one user to another
     * @param _sender The user to transfer the tokens from
     * @param _recipient The user to receive the tokens from _sender
     * @param _amount The amount of token to transfer
     * @return True if the transfer was successful
     */
    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        if (_amount == type(uint256).max) {
            _amount = balanceOf(_sender);
        }

        _mintAccruedInterest(_sender);
        _mintAccruedInterest(_recipient);

        if (balanceOf(_recipient) == 0) {
            s_userInterestRate[_recipient] = s_userInterestRate[_sender];
        }
        return super.transferFrom(_sender, _recipient, _amount);
    }

    /*
     * @notice Calculate the interest that has accumulated since the last update
     * @param _user The user to calculate the interest accumulated for
     * @return The interest that has accumulated since the last update
     */
    function _calculateUserAccumulatedInterestSinceLastUpdate(address _user)
        internal
        view
        returns (uint256 linearInterest)
    {
        // we need to calculate the interest that has accumulated since the last update
        // this is going to be linear growth with time
        // 1. calculate the time since the last update
        // 2. calculate the amount of linear growth

        // formula
        // User Token Balance + (User Token Balance * User Interest Rate * Time Elapsed)
        // User Token Balance * (1 + User Interest Rate * Time Elapsed)

        // Notes:
        // User Token Balance is handled in the balanceOf function
        // So we only handle (1 + User Interest Rate * Time Elapsed) for this function

        uint256 timeDifference = block.timestamp - s_userLastUpdatedTimestamp[_user];
        linearInterest = (s_userInterestRate[_user] * timeDifference) + PRECISION_FACTOR;
    }

    /*
     * @notice Mint the accrued interest to the user since the last time they interacted with the protocol
     * @param _user The user to mint the accrued interest to
     */
    function _mintAccruedInterest(address _user) internal {
        // Get the user's previous principal balance. The amount of tokens they had last time their interest was minted to them.
        uint256 previousPrincipalBalance = super.balanceOf(_user);

        // Calculate the accrued interest since the last accumulation
        // `balanceOf` uses the user's interest rate and the time since their last update to get the updated balance
        uint256 currentBalance = balanceOf(_user);
        uint256 balanceIncrease = currentBalance - previousPrincipalBalance;

        // Mint an amount of tokens equivalent to the interest accrued
        _mint(_user, balanceIncrease);
        // Update the user's last updated timestamp to reflect this most recent time their interest was minted to them.
        s_userLastUpdatedTimestamp[_user] = block.timestamp;
    }

    /*
     * @notice Get the interest rate that is currently set for contract. Any future sepositors will receive this interest rate
     * @return The interest rate for contract
     */
    function getInterestRate() external view returns (uint256) {
        return s_interestRate;
    }

    /*
     * @notice Get the interest rate for the user
     * @param _user The user to get the interest rate for
     * @return The interest rate for the user
     */
    function getUserInterestRate(address _user) external view returns (uint256) {
        return s_userInterestRate[_user];
    }
}
