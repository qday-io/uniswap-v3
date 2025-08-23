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
    function swapTokens(uint256 amountInEth) public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        address payable swapRouterAddress = payable(vm.envAddress("SWAP_ROUTER_ADDRESS"));
        
        ISwapRouter swapRouter = ISwapRouter(swapRouterAddress);
        
        // 将 ETH 转换为 wei
        uint256 amountInWei = amountInEth * 10**18;
        
        console.log("=== User Token Swap Operation ===");
        console.log("Amount to swap (ETH):");
        console.logUint(amountInEth);
        console.log("Amount to swap (wei):");
        console.logUint(amountInWei);
        
        // 检查用户余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 pqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        console.log("Balance before swap:");
        console.log("WETH:");
        console.logUint(wethBalance);
        console.log("PQUSD:");
        console.logUint(pqusdBalance);
        
        // 检查余额是否足够
        if (wethBalance < amountInWei) {
            console.log("Error: Insufficient WETH balance");
            console.log("Required:");
            console.logUint(amountInWei);
            console.log("Available:");
            console.logUint(wethBalance);
            return;
        }
        
        // 开始广播交易
        vm.startBroadcast(user);
        
        // 确保有足够的授权
        uint256 wethAllowance = IERC20(wethAddress).allowance(user, swapRouterAddress);
        console.log("WETH allowance:");
        console.logUint(wethAllowance);
        if (wethAllowance < amountInWei) {
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
                amountIn: amountInWei,
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
    function swapTokensReverse(uint256 amountInEth) public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        address payable swapRouterAddress = payable(vm.envAddress("SWAP_ROUTER_ADDRESS"));
        
        ISwapRouter swapRouter = ISwapRouter(swapRouterAddress);
        
        // 将 ETH 转换为 wei (注意：这里 amountInEth 实际上是以 ETH 为单位的 PQUSD 数量)
        uint256 amountInWei = amountInEth * 10**18;
        
        console.log("=== User Reverse Token Swap Operation ===");
        console.log("Amount to swap (PQUSD tokens):");
        console.logUint(amountInEth);
        console.log("Amount to swap (wei):");
        console.logUint(amountInWei);
        
        // 检查用户余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 pqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        console.log("Balance before swap:");
        console.log("WETH:");
        console.logUint(wethBalance);
        console.log("PQUSD:");
        console.logUint(pqusdBalance);
        
        // 检查 PQUSD 余额是否足够
        if (pqusdBalance < amountInWei) {
            console.log("Error: Insufficient PQUSD balance");
            console.log("Required:");
            console.logUint(amountInWei);
            console.log("Available:");
            console.logUint(pqusdBalance);
            return;
        }
        
        // 开始广播交易
        vm.startBroadcast(user);
        
        // 确保有足够的授权
        uint256 pqusdAllowance = IERC20(pqusdAddress).allowance(user, swapRouterAddress);
        console.log("PQUSD allowance:");
        console.logUint(pqusdAllowance);
        if (pqusdAllowance < amountInWei) {
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
                amountIn: amountInWei,
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
    
    
    // 用户操作：查询余额
    function checkUserBalance() public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        
        console.log("=== User Balance Query ===");
        console.log("User address:");
        console.logAddress(user);
        
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 pqusdBalance = IERC20(pqusdAddress).balanceOf(user);
        
        // 显示人类可读的余额格式
        console.log("=== Token Balances ===");
        console.log("WETH balance:");
        console.logUint(wethBalance / 10**18);
        
        console.log("PQUSD balance:");
        console.logUint(pqusdBalance / 10**18);
        
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
        
        console.log("Pool address:");
        console.logAddress(poolAddress);
        
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        
        // 获取池信息
        (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();
        
        console.log("Current sqrt price:");
        console.logUint(sqrtPriceX96);
        console.log("Current tick:");
        console.logInt(tick);
        
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
        console.log("Token0:");
        console.logAddress(token0);
        console.log("Token1:");
        console.logAddress(token1);
    }
    
    // 用户操作：查询流动性状态
    function checkLiquidityStatus() public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        console.log("=== User Liquidity Status ===");
        console.log("User address:");
        console.logAddress(user);
        
        // 查询流动性状态（如果有 tokenId）
        uint256 tokenId = vm.envUint("CREATED_TOKEN_ID");
        if (tokenId > 0) {
            console.log("=== Liquidity Position Status ===");
            console.log("Token ID:");
            console.logUint(tokenId);
            
            address positionManagerAddress = vm.envAddress("POSITION_MANAGER_ADDRESS");
            INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
            
            try positionManager.positions(tokenId) returns (
                uint96 nonce,
                address operator,
                address token0,
                address token1,
                uint24 fee,
                int24 tickLower,
                int24 tickUpper,
                uint128 liquidity,
                uint256 feeGrowthInside0LastX128,
                uint256 feeGrowthInside1LastX128,
                uint128 tokensOwed0,
                uint128 tokensOwed1
            ) {
                console.log("Position Details:");
                console.log("  Token0:");
                console.logAddress(token0);
                console.log("  Token1:");
                console.logAddress(token1);
                console.log("  Fee Tier:");
                console.logUint(fee);
                console.log("  Tick Lower:");
                console.logInt(tickLower);
                console.log("  Tick Upper:");
                console.logInt(tickUpper);
                console.log("  Current Liquidity:");
                console.logUint(liquidity);
                console.log("  Tokens Owed 0:");
                console.logUint(tokensOwed0);
                console.log("  Tokens Owed 1:");
                console.logUint(tokensOwed1);
                
                // 计算可收集的费用
                if (tokensOwed0 > 0 || tokensOwed1 > 0) {
                    console.log("=== Collectable Fees ===");
                    console.log("  Token0 fees:");
                    console.logUint(tokensOwed0);
                    console.log("  wei");
                    console.log("  Token1 fees:");
                    console.logUint(tokensOwed1);
                    console.log("  wei");
                } else {
                    console.log("No collectable fees at the moment");
                }
            } catch {
                console.log("Error: Could not retrieve position details for tokenId:");
                console.logUint(tokenId);
            }
        } else {
            console.log("No liquidity position found (CREATED_TOKEN_ID not set)");
        }
    }
    
    // 默认运行函数 - 执行用户交换操作
    function run() public {
        console.log("=== User Operation Script ===");
        console.log("Executing user token swap operation...");
        // 默认交换 1 ETH
        swapTokens(1);
    }
} 