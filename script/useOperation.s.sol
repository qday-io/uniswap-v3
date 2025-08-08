// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "forge-std/Script.sol";
import { ISwapRouter } from "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { INonfungiblePositionManager } from "../lib/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import { IUniswapV3Factory } from "../lib/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { IUniswapV3Pool } from "../lib/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { IERC20 } from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract UseOperation is Script {
    
    // 用户操作：执行代币交换
    function swapTokens() public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        address payable swapRouterAddress = payable(vm.envAddress("SWAP_ROUTER_ADDRESS"));
        
        ISwapRouter swapRouter = ISwapRouter(swapRouterAddress);
        
        console.log("=== User Token Swap Operation ===");
        
        // 检查用户余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 pqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        console.log("Balance before swap:");
        console.log("WETH:");
        console.logUint(wethBalance);
        console.log("PQUSD:");
        console.logUint(pqusdBalance);
        
        // 开始广播交易
        vm.startBroadcast(user);
        
        // 确保有足够的授权
        uint256 wethAllowance = IERC20(wethAddress).allowance(user, swapRouterAddress);
        console.log("WETH allowance:");
        console.logUint(wethAllowance);
        if (wethAllowance < 10000000000000000) { // 0.01 ETH
            IERC20(wethAddress).approve(swapRouterAddress, type(uint256).max);
            console.log("WETH approval set");
        } else {
            console.log("WETH already approved");
        }
        
        // 执行 WETH -> PQUSD 交换
        swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: wethAddress,
                tokenOut: pqusdAddress,
                fee: 3000,
                recipient: user,
                deadline: block.timestamp + 7200,
                amountIn: 10000000000000000, // 0.01 ETH
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            })
        );
        
        // 停止广播
        vm.stopBroadcast();
        
        console.log("Swap successful: WETH -> PQUSD");
        
        // 显示交换后余额
        uint256 newWethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 newPqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        console.log("Balance after swap:");
        console.log("WETH:");
        console.logUint(newWethBalance);
        console.log("PQUSD:");
        console.logUint(newPqusdBalance);
        
        // 计算并显示差额
        uint256 wethDifference = wethBalance - newWethBalance;
        uint256 pqusdDifference = newPqusdBalance - pqusdBalance;
        
        console.log("=== Balance Changes ===");
        console.log("WETH spent (wei):");
        console.logUint(wethDifference);
        console.log("WETH spent (ETH):");
        console.logUint(wethDifference / 10**18);
        console.log("PQUSD received (wei):");
        console.logUint(pqusdDifference);
        console.log("PQUSD received (tokens):");
        console.logUint(pqusdDifference / 10**18);
    }
    
    // 用户操作：反向交换 (PQUSD -> WETH)
    function swapTokensReverse() public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        address payable swapRouterAddress = payable(vm.envAddress("SWAP_ROUTER_ADDRESS"));
        
        ISwapRouter swapRouter = ISwapRouter(swapRouterAddress);
        
        console.log("=== User Reverse Token Swap Operation ===");
        
        // 检查用户余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 pqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        console.log("Balance before swap:");
        console.log("WETH:");
        console.logUint(wethBalance);
        console.log("PQUSD:");
        console.logUint(pqusdBalance);
        
        // 开始广播交易
        vm.startBroadcast(user);
        
        // 确保有足够的授权
        uint256 pqusdAllowance = IERC20(pqusdAddress).allowance(user, swapRouterAddress);
        console.log("PQUSD allowance:");
        console.logUint(pqusdAllowance);
        if (pqusdAllowance < 100000000000000000000) { // 100 tokens
            IERC20(pqusdAddress).approve(swapRouterAddress, type(uint256).max);
            console.log("PQUSD approval set");
        } else {
            console.log("PQUSD already approved");
        }
        
        // 执行 PQUSD -> WETH 交换
        swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: pqusdAddress,
                tokenOut: wethAddress,
                fee: 3000,
                recipient: user,
                deadline: block.timestamp + 7200,
                amountIn: 50000000000000000000, // 50 tokens
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            })
        );
        
        // 停止广播
        vm.stopBroadcast();
        
        console.log("Swap successful: PQUSD -> WETH");
        
        // 显示交换后余额
        uint256 newWethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 newPqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        console.log("Balance after swap:");
        console.log("WETH:");
        console.logUint(newWethBalance);
        console.log("PQUSD:");
        console.logUint(newPqusdBalance);
        
        // 计算并显示差额
        uint256 wethDifference = newWethBalance - wethBalance;
        uint256 pqusdDifference = pqusdBalance - newPqusdBalance;
        
        console.log("=== Balance Changes ===");
        console.log("WETH received (wei):");
        console.logUint(wethDifference);
        console.log("WETH received (ETH):");
        console.logUint(wethDifference / 10**18);
        console.log("PQUSD spent (wei):");
        console.logUint(pqusdDifference);
        console.log("PQUSD spent (tokens):");
        console.logUint(pqusdDifference / 10**18);
    }
    
    // 用户操作：添加流动性
    function addUserLiquidity() public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        console.log("=== User Add Liquidity Operation ===");
        
        // 检查用户余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 pqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        console.log("Balance before adding liquidity:");
        console.log("WETH:");
        console.logUint(wethBalance);
        console.log("PQUSD:");
        console.logUint(pqusdBalance);
        
        // 开始广播交易
        vm.startBroadcast(user);
        
        // 确保有足够的授权
        if (IERC20(wethAddress).allowance(user, positionManagerAddress) < 100000000000000000000) { // 100 ETH
            IERC20(wethAddress).approve(positionManagerAddress, type(uint256).max);
            console.log("WETH approval set for PositionManager");
        }
        
        if (IERC20(pqusdAddress).allowance(user, positionManagerAddress) < 100000000000000000000000) { // 100000 tokens
            IERC20(pqusdAddress).approve(positionManagerAddress, type(uint256).max);
            console.log("PQUSD approval set for PositionManager");
        }
        
        // 添加流动性
        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: wethAddress < pqusdAddress ? wethAddress : pqusdAddress,
                token1: wethAddress < pqusdAddress ? pqusdAddress : wethAddress,
                fee: 3000,
                tickLower: -887220,
                tickUpper: 887220,
                amount0Desired: 10000000000000000, // 0.01 ETH
                amount1Desired: 10000000000000000000, // 10 tokens
                amount0Min: 0,
                amount1Min: 0,
                recipient: user,
                deadline: block.timestamp + 7200
            })
        );
        
        // 停止广播
        vm.stopBroadcast();
        
        console.log("Liquidity added successfully!");
        console.log("TokenId:");
        console.logUint(tokenId);
        console.log("Liquidity amount:");
        console.logUint(liquidity);
        console.log("Token0 used:");
        console.logUint(amount0);
        console.log("Token1 used:");
        console.logUint(amount1);
        
        // 显示添加后的余额
        uint256 newWethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 newPqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        console.log("Balance after adding liquidity:");
        console.log("WETH:");
        console.logUint(newWethBalance);
        console.log("PQUSD:");
        console.logUint(newPqusdBalance);
        
        // 计算并显示差额
        uint256 wethDifference = wethBalance - newWethBalance;
        uint256 pqusdDifference = pqusdBalance - newPqusdBalance;
        
        console.log("=== Balance Changes ===");
        console.log("WETH used (wei):");
        console.logUint(wethDifference);
        console.log("WETH used (ETH):");
        console.logUint(wethDifference / 10**18);
        console.log("PQUSD used (wei):");
        console.logUint(pqusdDifference);
        console.log("PQUSD used (tokens):");
        console.logUint(pqusdDifference / 10**18);
    }
    
    // 用户操作：查询余额
    function checkUserBalance() public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        
        console.log("=== User Balance Query ===");
        console.log("User address:", user);
        
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 pqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        // 显示人类可读的余额格式
        console.log("=== Token Balances ===");
        console.log("WETH balance:");
        // console.log("  Raw (wei):");
        // console.logUint(wethBalance);
        // console.log("  Human readable:");
        console.logUint(wethBalance / 10**18);
        
        console.log("PQUSD balance:");
        // console.log("  Raw (wei):");
        // console.logUint(pqusdBalance);
        // console.log("  Human readable:");
        console.logUint(pqusdBalance / 10**18);
        // console.log("  Decimals:");
        // console.logUint(pqusdBalance % 10**18);
        
        // 显示授权情况
        address payable swapRouterAddress = payable(vm.envAddress("SWAP_ROUTER_ADDRESS"));
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        
        uint256 wethSwapAllowance = IERC20(wethAddress).allowance(user, swapRouterAddress);
        uint256 pqusdSwapAllowance = IERC20(pqusdAddress).allowance(user, swapRouterAddress);
        uint256 wethPositionAllowance = IERC20(wethAddress).allowance(user, positionManagerAddress);
        uint256 pqusdPositionAllowance = IERC20(pqusdAddress).allowance(user, positionManagerAddress);
        
        console.log("=== Approval Status ===");
        console.log("WETH -> SwapRouter (wei):");
        console.logUint(wethSwapAllowance);
        
        console.log("PQUSD -> SwapRouter (wei):");
        console.logUint(pqusdSwapAllowance);
        
        console.log("WETH -> PositionManager (wei):");
        console.logUint(wethPositionAllowance);
        
        console.log("PQUSD -> PositionManager (wei):");
        console.logUint(pqusdPositionAllowance);
        
        // 检查是否为最大授权
        console.log("=== Authorization Check ===");
        if (wethSwapAllowance == type(uint256).max) {
            console.log("WETH -> SwapRouter: MAX APPROVAL");
        } else {
            console.log("WETH -> SwapRouter: LIMITED APPROVAL");
        }
        
        if (pqusdSwapAllowance == type(uint256).max) {
            console.log("PQUSD -> SwapRouter: MAX APPROVAL");
        } else {
            console.log("PQUSD -> SwapRouter: LIMITED APPROVAL");
        }
        
        if (wethPositionAllowance == type(uint256).max) {
            console.log("WETH -> PositionManager: MAX APPROVAL");
        } else {
            console.log("WETH -> PositionManager: LIMITED APPROVAL");
        }
        
        if (pqusdPositionAllowance == type(uint256).max) {
            console.log("PQUSD -> PositionManager: MAX APPROVAL");
        } else {
            console.log("PQUSD -> PositionManager: LIMITED APPROVAL");
        }
    }
    
    // 用户操作：查询池信息
    function checkPoolInfo() public {
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        address payable factoryAddress = payable(vm.envAddress("FACTORY_ADDRESS"));
        
        IUniswapV3Factory factory = IUniswapV3Factory(factoryAddress);
        
        console.log("=== Pool Information ===");
        
        // 获取池地址
        address poolAddress = factory.getPool(wethAddress, pqusdAddress, 3000);
        
        if (poolAddress == address(0)) {
            console.log("Pool does not exist");
            return;
        }
        
        console.log("Pool address:", poolAddress);
        
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        
        // 获取池信息
        (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();
        
        console.log("Current sqrt price:");
        console.logUint(sqrtPriceX96);
        console.log("Current tick:");
        console.logUint(uint256(int256(tick)));
        
        // 获取流动性信息
        uint128 liquidity = pool.liquidity();
        console.log("Current liquidity:");
        console.logUint(liquidity);
        
        // 获取费用信息
        uint24 fee = pool.fee();
        console.log("Fee tier:");
        console.logUint(fee);
        
        // 获取代币地址
        address token0 = pool.token0();
        address token1 = pool.token1();
        console.log("Token0:", token0);
        console.log("Token1:", token1);
    }
    
    // 默认运行函数 - 执行用户交换操作
    function run() public {
        console.log("=== User Operation Script ===");
        console.log("Executing user token swap operation...");
        swapTokens();
    }
} 