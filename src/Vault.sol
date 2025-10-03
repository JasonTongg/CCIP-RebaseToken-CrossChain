// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

contract Vault {
    IRebaseToken private immutable i_rebaseToken;

    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);

    error Vault__RedeemFailed();

    constructor(IRebaseToken _rebaseToken) {
        i_rebaseToken = _rebaseToken;
    }

    receive() external payable {}

    /*
    * @notice Get the address of the rebase token
    * @return The address of the token
    */
    function getRebaseTokenAddress() external view returns (address) {
        return address(i_rebaseToken);
    }

    /*
    * @notice Allows users to deposit ETH into the vault and mint rebase tokens
    */
    function deposit() external payable {
        // 1. we need to use the amount of ETH the user has sent to the user
        i_rebaseToken.mint(msg.sender, msg.value, i_rebaseToken.getInterestRate());
        emit Deposit(msg.sender, msg.value);
    }

    /*
    * @notice Allows users to redeem thier rebase tokens for ETH
    * @param _amount The amount of rebase token to redeem
    */
    function redeem(uint256 _amount) external {
        if (_amount == type(uint96).max) {
            _amount = i_rebaseToken.balanceOf(msg.sender);
        }
        // 1. burn the tokens from the user
        i_rebaseToken.burn(msg.sender, _amount);
        // 2. we need to send the user eth
        (bool success,) = payable(address(msg.sender)).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }

        emit Redeem(msg.sender, _amount);
    }
}
