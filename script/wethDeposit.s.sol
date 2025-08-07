// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "forge-std/Script.sol";

contract WETHDeposit is Script {
    
    function run() public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        
        // 计算 deposit 数额：1000 * 10^18
        uint256 depositAmount = 1000 * 10**18;
        
        // === WETH Deposit Operation ===
        
        // 检查用户当前余额
        uint256 userBalance = user.balance;
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        
        // Balance before deposit:
        // User ETH balance: userBalance
        // User WETH balance: wethBalance
        
        // 开始广播交易
        vm.startBroadcast(user);
        
        // 执行 deposit 操作
        // 注意：我们需要发送 ETH 到 WETH 合约
        (bool success, ) = wethAddress.call{value: depositAmount}("");
        require(success, "Deposit failed");
        
        // 停止广播
        vm.stopBroadcast();
        
        // Deposit successful!
        // Amount deposited: depositAmount
        
        // 检查 deposit 后的余额
        uint256 newUserBalance = user.balance;
        uint256 newWethBalance = IERC20(wethAddress).balanceOf(user);
        
        // Balance after deposit:
        // User ETH balance: newUserBalance
        // User WETH balance: newWethBalance
    }
}

// 简单的 IERC20 接口
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
} 