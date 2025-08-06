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
        address payable testTokenAddress = payable(vm.envAddress("TEST_TOKEN_ADDRESS"));
        address payable swapRouterAddress = payable(vm.envAddress("SWAP_ROUTER_ADDRESS"));
        
        ISwapRouter swapRouter = ISwapRouter(swapRouterAddress);
        
        console.log("=== User Token Swap Operation ===");
        
        // 检查用户余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 testTokenBalance = IERC20(testTokenAddress).balanceOf(user);
        
        console.log("Balance before swap:");
        console.log("WETH:", wethBalance);
        console.log("TestToken:", testTokenBalance);
        
        // 确保有足够的授权
        uint256 wethAllowance = IERC20(wethAddress).allowance(user, swapRouterAddress);
        if (wethAllowance < 10000000000000000) { // 0.01 ETH
            vm.prank(user);
            IERC20(wethAddress).approve(swapRouterAddress, type(uint256).max);
            console.log("WETH approval set");
        }
        
        // 执行 WETH -> TestToken 交换
        vm.prank(user);
        swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: wethAddress,
                tokenOut: testTokenAddress,
                fee: 3000,
                recipient: user,
                deadline: block.timestamp + 300,
                amountIn: 10000000000000000, // 0.01 ETH
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            })
        );
        
        console.log("Swap successful: WETH -> TestToken");
        
        // 显示交换后余额
        uint256 newWethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 newTestTokenBalance = IERC20(testTokenAddress).balanceOf(user);
        
        console.log("Balance after swap:");
        console.log("WETH:", newWethBalance);
        console.log("TestToken:", newTestTokenBalance);
    }
    
    // 用户操作：反向交换 (TestToken -> WETH)
    function swapTokensReverse() public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable testTokenAddress = payable(vm.envAddress("TEST_TOKEN_ADDRESS"));
        address payable swapRouterAddress = payable(vm.envAddress("SWAP_ROUTER_ADDRESS"));
        
        ISwapRouter swapRouter = ISwapRouter(swapRouterAddress);
        
        console.log("=== User Reverse Token Swap Operation ===");
        
        // 检查用户余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 testTokenBalance = IERC20(testTokenAddress).balanceOf(user);
        
        console.log("Balance before swap:");
        console.log("WETH:", wethBalance);
        console.log("TestToken:", testTokenBalance);
        
        // 确保有足够的授权
        uint256 testTokenAllowance = IERC20(testTokenAddress).allowance(user, swapRouterAddress);
        if (testTokenAllowance < 100000000000000000000) { // 100 tokens
            vm.prank(user);
            IERC20(testTokenAddress).approve(swapRouterAddress, type(uint256).max);
            console.log("TestToken approval set");
        }
        
        // 执行 TestToken -> WETH 交换
        vm.prank(user);
        swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: testTokenAddress,
                tokenOut: wethAddress,
                fee: 3000,
                recipient: user,
                deadline: block.timestamp + 300,
                amountIn: 50000000000000000000, // 50 tokens
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            })
        );
        
        console.log("Swap successful: TestToken -> WETH");
        
        // 显示交换后余额
        uint256 newWethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 newTestTokenBalance = IERC20(testTokenAddress).balanceOf(user);
        
        console.log("Balance after swap:");
        console.log("WETH:", newWethBalance);
        console.log("TestToken:", newTestTokenBalance);
    }
    
    // 用户操作：添加流动性
    function addUserLiquidity() public {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable testTokenAddress = payable(vm.envAddress("TEST_TOKEN_ADDRESS"));
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        console.log("=== User Add Liquidity Operation ===");
        
        // 检查用户余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 testTokenBalance = IERC20(testTokenAddress).balanceOf(user);
        
        console.log("Balance before adding liquidity:");
        console.log("WETH:", wethBalance);
        console.log("TestToken:", testTokenBalance);
        
        // 确保有足够的授权
        uint256 wethAllowance = IERC20(wethAddress).allowance(user, positionManagerAddress);
        uint256 testTokenAllowance = IERC20(testTokenAddress).allowance(user, positionManagerAddress);
        
        if (wethAllowance < 100000000000000000) { // 0.1 ETH
            vm.prank(user);
            IERC20(wethAddress).approve(positionManagerAddress, type(uint256).max);
            console.log("WETH approval set");
        }
        
        if (testTokenAllowance < 100000000000000000000) { // 100 tokens
            vm.prank(user);
            IERC20(testTokenAddress).approve(positionManagerAddress, type(uint256).max);
            console.log("TestToken approval set");
        }
        
        // 添加流动性
        vm.prank(user);
        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: wethAddress < testTokenAddress ? wethAddress : testTokenAddress,
                token1: wethAddress < testTokenAddress ? testTokenAddress : wethAddress,
                fee: 3000,
                tickLower: -887220,
                tickUpper: 887220,
                amount0Desired: 50000000000000000, // 0.05 ETH
                amount1Desired: 50000000000000000000, // 50 tokens
                amount0Min: 0,
                amount1Min: 0,
                recipient: user,
                deadline: block.timestamp + 300
            })
        );
        
        console.log("Liquidity added successfully!");
        console.log("TokenId:", tokenId);
        console.log("Liquidity amount:", liquidity);
        console.log("Token0 used:", amount0);
        console.log("Token1 used:", amount1);
        
        // 显示添加后的余额
        uint256 newWethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 newTestTokenBalance = IERC20(testTokenAddress).balanceOf(user);
        
        console.log("Balance after adding liquidity:");
        console.log("WETH:", newWethBalance);
        console.log("TestToken:", newTestTokenBalance);
    }
    
    // 用户操作：查询余额
    function checkUserBalance() public view {
        address user = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable testTokenAddress = payable(vm.envAddress("TEST_TOKEN_ADDRESS"));
        
        console.log("=== User Balance Query ===");
        console.log("User address:", user);
        
        uint256 wethBalance = IERC20(wethAddress).balanceOf(user);
        uint256 testTokenBalance = IERC20(testTokenAddress).balanceOf(user);
        
        console.log("WETH balance:", wethBalance);
        console.log("TestToken balance:", testTokenBalance);
        
        // 显示授权情况
        address payable swapRouterAddress = payable(vm.envAddress("SWAP_ROUTER_ADDRESS"));
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        
        uint256 wethSwapAllowance = IERC20(wethAddress).allowance(user, swapRouterAddress);
        uint256 testTokenSwapAllowance = IERC20(testTokenAddress).allowance(user, swapRouterAddress);
        uint256 wethPositionAllowance = IERC20(wethAddress).allowance(user, positionManagerAddress);
        uint256 testTokenPositionAllowance = IERC20(testTokenAddress).allowance(user, positionManagerAddress);
        
        console.log("Approval status:");
        console.log("WETH -> SwapRouter:", wethSwapAllowance);
        console.log("TestToken -> SwapRouter:", testTokenSwapAllowance);
        console.log("WETH -> PositionManager:", wethPositionAllowance);
        console.log("TestToken -> PositionManager:", testTokenPositionAllowance);
    }
    
    // 用户操作：查询池信息
    function checkPoolInfo() public view {
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable testTokenAddress = payable(vm.envAddress("TEST_TOKEN_ADDRESS"));
        address payable factoryAddress = payable(vm.envAddress("FACTORY_ADDRESS"));
        
        IUniswapV3Factory factory = IUniswapV3Factory(factoryAddress);
        
        console.log("=== Pool Information Query ===");
        
        address poolAddress = factory.getPool(wethAddress, testTokenAddress, 3000);
        
        if (poolAddress == address(0)) {
            console.log("Pool does not exist");
            return;
        }
        
        console.log("Pool address:", poolAddress);
        
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        
        // 获取池的基本信息
        (uint160 sqrtPriceX96, int24 tick,,,,,,) = pool.slot0();
        
        console.log("Current price (sqrtPriceX96):", sqrtPriceX96);
        console.log("Current tick:", tick);
        
        // 获取流动性信息
        uint128 liquidity = pool.liquidity();
        console.log("Current liquidity:", liquidity);
        
        // 获取费用信息
        uint24 fee = pool.fee();
        console.log("Fee tier:", fee);
        
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