// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/SimpleTokenWallet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Minimal ERC20 for testing
 */
contract MockERC20 is ERC20 {
    constructor() ERC20("MockERC20", "MK20") {
        _mint(msg.sender, 1_000_000e18);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract SimpleTokenWalletTest is Test {
    SimpleTokenWallet public wallet;
    MockERC20 public mockToken;
    MockERC20 public secondToken;

    address alice = address(0xA11CE);
    address bob = address(0xB0B);
    address carol = address(0xCA201);

    event Deposit(address indexed from, address indexed token, uint256 amount);
    event Withdrawal(address indexed to, address indexed token, uint256 amount);

    function setUp() public {
        wallet = new SimpleTokenWallet();
        mockToken = new MockERC20();
        secondToken = new MockERC20();

        // Initial token distribution
        mockToken.mint(alice, 5000 ether);
        mockToken.mint(bob, 3000 ether);
        secondToken.mint(alice, 1000 ether);
    }

    function testInitialBalanceIsZero() public {
        assertEq(wallet.balanceOf(alice, address(mockToken)), 0);
        assertEq(wallet.balanceOf(bob, address(mockToken)), 0);
    }

    function testBasicDepositAndWithdraw() public {
        // Alice deposits 1000 tokens
        vm.startPrank(alice);
        mockToken.approve(address(wallet), 1000 ether);
        wallet.deposit(address(mockToken), 1000 ether);
        assertEq(wallet.balanceOf(alice, address(mockToken)), 1000 ether);

        // Withdraw 500
        wallet.withdraw(address(mockToken), 500 ether);
        assertEq(wallet.balanceOf(alice, address(mockToken)), 500 ether);
        vm.stopPrank();
    }

    function testMultipleUsersMultipleTokens() public {
        // Alice deposits both tokens
        vm.startPrank(alice);
        mockToken.approve(address(wallet), 1000 ether);
        secondToken.approve(address(wallet), 500 ether);
        
        wallet.deposit(address(mockToken), 1000 ether);
        wallet.deposit(address(secondToken), 500 ether);
        
        assertEq(wallet.balanceOf(alice, address(mockToken)), 1000 ether);
        assertEq(wallet.balanceOf(alice, address(secondToken)), 500 ether);
        vm.stopPrank();

        // Bob deposits mockToken
        vm.startPrank(bob);
        mockToken.approve(address(wallet), 2000 ether);
        wallet.deposit(address(mockToken), 2000 ether);
        assertEq(wallet.balanceOf(bob, address(mockToken)), 2000 ether);
        vm.stopPrank();
    }

    function testDepositZeroAmount() public {
        vm.startPrank(alice);
        mockToken.approve(address(wallet), 0);
        vm.expectRevert("Deposit amount must be > 0");
        wallet.deposit(address(mockToken), 0);
        vm.stopPrank();
    }

    function testWithdrawTooMuch() public {
        vm.startPrank(alice);
        mockToken.approve(address(wallet), 100 ether);
        wallet.deposit(address(mockToken), 100 ether);
        
        vm.expectRevert("Insufficient balance");
        wallet.withdraw(address(mockToken), 200 ether);
        vm.stopPrank();
    }

    function testDepositInvalidToken() public {
        vm.startPrank(alice);
        vm.expectRevert("Invalid token address");
        wallet.deposit(address(0), 100 ether);
        vm.stopPrank();
    }

    function testWithdrawInvalidToken() public {
        vm.startPrank(alice);
        vm.expectRevert("Invalid token address");
        wallet.withdraw(address(0), 100 ether);
        vm.stopPrank();
    }

    function testDepositEmitsEvent() public {
        vm.startPrank(alice);
        mockToken.approve(address(wallet), 1000 ether);
        
        vm.expectEmit(true, true, false, true);
        emit Deposit(alice, address(mockToken), 1000 ether);
        wallet.deposit(address(mockToken), 1000 ether);
        vm.stopPrank();
    }

    function testWithdrawEmitsEvent() public {
        vm.startPrank(alice);
        mockToken.approve(address(wallet), 1000 ether);
        wallet.deposit(address(mockToken), 1000 ether);
        
        vm.expectEmit(true, true, false, true);
        emit Withdrawal(alice, address(mockToken), 500 ether);
        wallet.withdraw(address(mockToken), 500 ether);
        vm.stopPrank();
    }

    function testBalanceAfterMultipleOperations() public {
        // Alice makes multiple deposits and withdrawals
        vm.startPrank(alice);
        mockToken.approve(address(wallet), 5000 ether);
        
        wallet.deposit(address(mockToken), 1000 ether);
        wallet.deposit(address(mockToken), 500 ether);
        wallet.withdraw(address(mockToken), 300 ether);
        wallet.deposit(address(mockToken), 200 ether);
        wallet.withdraw(address(mockToken), 100 ether);
        
        // Final balance should be: 1000 + 500 - 300 + 200 - 100 = 1300
        assertEq(wallet.balanceOf(alice, address(mockToken)), 1300 ether);
        vm.stopPrank();
    }
} 