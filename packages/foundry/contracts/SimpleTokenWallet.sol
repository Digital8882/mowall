// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SimpleTokenWallet
 * @notice A minimal ERC20 token wallet that handles deposits, withdrawals,
 *         balance tracking, and emits events for all actions.
 */
contract SimpleTokenWallet is Context, ReentrancyGuard {
    /**
     * @dev tokenBalances[user][token] => how many of `token` does `user` own
     */
    mapping(address => mapping(address => uint256)) public tokenBalances;

    /**
     * @notice Emitted when a deposit of `amount` of `token` is made by `from`
     */
    event Deposit(address indexed from, address indexed token, uint256 amount);

    /**
     * @notice Emitted when a withdrawal of `amount` of `token` is made by `to`
     */
    event Withdrawal(address indexed to, address indexed token, uint256 amount);

    /**
     * @notice Deposit `amount` of `token` into this wallet for `msg.sender`
     * @dev Caller must have approved this contract before calling deposit.
     */
    function deposit(address token, uint256 amount) external nonReentrant {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Deposit amount must be > 0");

        bool success = IERC20(token).transferFrom(_msgSender(), address(this), amount);
        require(success, "Token transfer failed");

        tokenBalances[_msgSender()][token] += amount;

        emit Deposit(_msgSender(), token, amount);
    }

    /**
     * @notice Withdraw `amount` of `token` from the wallet
     */
    function withdraw(address token, uint256 amount) external nonReentrant {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Withdraw amount must be > 0");
        require(tokenBalances[_msgSender()][token] >= amount, "Insufficient balance");

        tokenBalances[_msgSender()][token] -= amount;

        bool success = IERC20(token).transfer(_msgSender(), amount);
        require(success, "Token transfer failed");

        emit Withdrawal(_msgSender(), token, amount);
    }

    /**
     * @notice Convenience function: check how many `token` a user has
     */
    function balanceOf(address user, address token) external view returns (uint256) {
        return tokenBalances[user][token];
    }
} 