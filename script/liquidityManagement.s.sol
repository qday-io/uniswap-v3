// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "forge-std/Script.sol";
import { INonfungiblePositionManager } from "../lib/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import { IUniswapV3Factory } from "../lib/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { IUniswapV3Pool } from "../lib/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { IERC20 } from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LiquidityManagement is Script {
    // 存储创建的 position tokenId
    uint256 public createdTokenId;
    
    function run() public {
        // 默认运行完整流程
        runFullFlow();
    }
    
    // 运行完整流程
    function runFullFlow() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable testTokenAddress = payable(vm.envAddress("TEST_TOKEN_ADDRESS"));
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        address payable factoryAddress = payable(vm.envAddress("FACTORY_ADDRESS"));
        
        // 获取合约实例
        IUniswapV3Factory factory = IUniswapV3Factory(factoryAddress);
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        // 确保有足够的授权
        _ensureAllowances(deployer, wethAddress, testTokenAddress, positionManagerAddress);
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 确保池存在并已初始化
        address poolAddress = factory.getPool(wethAddress, testTokenAddress, 3000);
        if (poolAddress == address(0)) {
            poolAddress = factory.createPool(wethAddress, testTokenAddress, 3000);
        }
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        
        // 检查池是否已初始化
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
        if (sqrtPriceX96 == 0) {
            pool.initialize(1000000000000000000000000); // 1e24
        }
        
        // 执行流动性管理操作
        _addLiquidity(deployer, positionManager, wethAddress, testTokenAddress);
        _increaseLiquidity(deployer, positionManager, wethAddress, testTokenAddress);
        // _collectFees(deployer, positionManager);
        // _decreaseLiquidity(deployer, positionManager);
        // _burnPosition(deployer, positionManager);
        
        // 停止广播
        vm.stopBroadcast();
    }
    
    function _ensureAllowances(
        address deployer,
        address wethAddress,
        address testTokenAddress,
        address positionManagerAddress
    ) internal {
        // 检查并设置 WETH 授权
        uint256 wethAllowance = IERC20(wethAddress).allowance(deployer, positionManagerAddress);
        if (wethAllowance < 1000000000000000000) { // 1 ETH
            IERC20(wethAddress).approve(positionManagerAddress, type(uint256).max);
        }
        
        // 检查并设置 TestToken 授权
        uint256 testTokenAllowance = IERC20(testTokenAddress).allowance(deployer, positionManagerAddress);
        if (testTokenAllowance < 1000000000000000000000) { // 1000 tokens
            IERC20(testTokenAddress).approve(positionManagerAddress, type(uint256).max);
        }
    }
    
    function _addLiquidity(
        address deployer,
        INonfungiblePositionManager positionManager,
        address wethAddress,
        address testTokenAddress
    ) internal {
        console.log("=== Add Liquidity ===");
        
        // 获取当前余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(deployer);
        uint256 testTokenBalance = IERC20(testTokenAddress).balanceOf(deployer);
        
        console.log("Balance before adding liquidity:");
        console.log("  WETH (wei):");
        console.logUint(wethBalance);
        console.log("  WETH (ETH):");
        console.logUint(wethBalance / 10**18);
        console.log("  TestToken (wei):");
        console.logUint(testTokenBalance);
        console.log("  TestToken (tokens):");
        console.logUint(testTokenBalance / 10**18);
        
        // 创建流动性位置
        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: wethAddress < testTokenAddress ? wethAddress : testTokenAddress,
                token1: wethAddress < testTokenAddress ? testTokenAddress : wethAddress,
                fee: 3000,
                tickLower: -887220,
                tickUpper: 887220,
                amount0Desired: 100000000000000000, // 0.1 ETH
                amount1Desired: 100000000000000000000, // 100 tokens
                amount0Min: 0,
                amount1Min: 0,
                recipient: deployer,
                deadline: block.timestamp + 3600
            })
        );
        
        createdTokenId = tokenId;
        
        console.log("=== Liquidity Added Successfully ===");
        console.log("TokenId:");
        console.logUint(tokenId);
        console.log("Liquidity amount:");
        console.logUint(liquidity);
        console.log("Token0 used (wei):");
        console.logUint(amount0);
        console.log("Token1 used (wei):");
        console.logUint(amount1);
        
        // 显示添加后的余额
        uint256 newWethBalance = IERC20(wethAddress).balanceOf(deployer);
        uint256 newTestTokenBalance = IERC20(testTokenAddress).balanceOf(deployer);
        
        console.log("=== Balance After Adding Liquidity ===");
        console.log("WETH (wei):");
        console.logUint(newWethBalance);
        console.log("WETH (ETH):");
        console.logUint(newWethBalance / 10**18);
        console.log("TestToken (wei):");
        console.logUint(newTestTokenBalance);
        console.log("TestToken (tokens):");
        console.logUint(newTestTokenBalance / 10**18);
        
        // 计算并显示差额
        uint256 wethDifference = wethBalance - newWethBalance;
        uint256 testTokenDifference = testTokenBalance - newTestTokenBalance;
        
        console.log("=== Balance Changes ===");
        console.log("WETH used (wei):");
        console.logUint(wethDifference);
        console.log("WETH used (ETH):");
        console.logUint(wethDifference / 10**18);
        console.log("TestToken used (wei):");
        console.logUint(testTokenDifference);
        console.log("TestToken used (tokens):");
        console.logUint(testTokenDifference / 10**18);
    }
    
    function _increaseLiquidity(
        address deployer,
        INonfungiblePositionManager positionManager,
        address wethAddress,
        address testTokenAddress
    ) internal {
        console.log("=== Increase Liquidity ===");
        
        // 获取位置信息
        (,,,,,,,uint128 currentLiquidity,,,,) = positionManager.positions(createdTokenId);
        
        console.log("Current liquidity:");
        console.logUint(currentLiquidity);
        
        // 增加流动性
        (uint128 newLiquidity, uint256 amount0, uint256 amount1) = positionManager.increaseLiquidity(
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: createdTokenId,
                amount0Desired: 50000000000000000, // 0.05 ETH
                amount1Desired: 50000000000000000000, // 50 tokens
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp + 3600
            })
        );
        
        console.log("=== Liquidity Increased Successfully ===");
        console.log("New liquidity added:");
        console.logUint(newLiquidity);
        console.log("Token0 used (wei):");
        console.logUint(amount0);
        console.log("Token1 used (wei):");
        console.logUint(amount1);
        
        // 显示增加后的总流动性
        (,,,,,,,uint128 totalLiquidity,,,,) = positionManager.positions(createdTokenId);
        
        console.log("=== Total Liquidity After Increase ===");
        console.log("Total liquidity:");
        console.logUint(totalLiquidity);
        
        // 计算并显示流动性增加量
        uint128 liquidityIncrease = totalLiquidity - currentLiquidity;
        
        console.log("=== Liquidity Changes ===");
        console.log("Liquidity increase:");
        console.logUint(liquidityIncrease);
        console.log("Previous liquidity:");
        console.logUint(currentLiquidity);
        console.log("New total liquidity:");
        console.logUint(totalLiquidity);
    }
    
    function _collectFees(
        address deployer,
        INonfungiblePositionManager positionManager
    ) internal {
        console.log("=== Collect Fees ===");
        
        // 获取当前欠款
        (,,,,,,,,,,uint128 tokensOwed0,uint128 tokensOwed1) = positionManager.positions(createdTokenId);
        
        console.log("Current fees owed:");
        console.log("  Token0 owed (wei):");
        console.logUint(tokensOwed0);
        console.log("  Token1 owed (wei):");
        console.logUint(tokensOwed1);
        
        // 收集费用
        (uint256 amount0, uint256 amount1) = positionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: createdTokenId,
                recipient: deployer,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        
        console.log("=== Fees Collected Successfully ===");
        console.log("Token0 collected (wei):");
        console.logUint(amount0);
        console.log("Token1 collected (wei):");
        console.logUint(amount1);
    }
    
    function _decreaseLiquidity(
        address deployer,
        INonfungiblePositionManager positionManager
    ) internal {
        console.log("=== Decrease Liquidity ===");
        
        // 获取当前流动性
        (,,,,,,,uint128 currentLiquidity,,,,) = positionManager.positions(createdTokenId);
        
        console.log("Current liquidity:");
        console.logUint(currentLiquidity);
        
        // 减少一半流动性
        uint128 decreaseAmount = currentLiquidity / 2;
        
        console.log("Decreasing liquidity by:");
        console.logUint(decreaseAmount);
        
        (uint256 amount0, uint256 amount1) = positionManager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: createdTokenId,
                liquidity: decreaseAmount,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp + 3600
            })
        );
        
        console.log("=== Liquidity Decreased Successfully ===");
        console.log("Decreased liquidity:");
        console.logUint(decreaseAmount);
        console.log("Token0 returned (wei):");
        console.logUint(amount0);
        console.log("Token1 returned (wei):");
        console.logUint(amount1);
        
        // 显示减少后的流动性
        (,,,,,,,uint128 remainingLiquidity,,,,) = positionManager.positions(createdTokenId);
        
        console.log("=== Remaining Liquidity ===");
        console.log("Remaining liquidity:");
        console.logUint(remainingLiquidity);
        
        // 计算并显示流动性减少量
        uint128 liquidityDecrease = currentLiquidity - remainingLiquidity;
        
        console.log("=== Liquidity Changes ===");
        console.log("Liquidity decrease:");
        console.logUint(liquidityDecrease);
        console.log("Previous liquidity:");
        console.logUint(currentLiquidity);
        console.log("Remaining liquidity:");
        console.logUint(remainingLiquidity);
    }
    
    function _burnPosition(
        address deployer,
        INonfungiblePositionManager positionManager
    ) internal {
        console.log("=== Burn Position ===");
        console.log("TokenId to burn:");
        console.logUint(createdTokenId);
        
        // 首先收集所有剩余费用
        console.log("Collecting remaining fees...");
        positionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: createdTokenId,
                recipient: deployer,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        
        // 减少所有剩余流动性
        (,,,,,,,uint128 remainingLiquidity,,,,) = positionManager.positions(createdTokenId);
        
        console.log("Remaining liquidity before burn:");
        console.logUint(remainingLiquidity);
        
        if (remainingLiquidity > 0) {
            console.log("Decreasing remaining liquidity...");
            positionManager.decreaseLiquidity(
                INonfungiblePositionManager.DecreaseLiquidityParams({
                    tokenId: createdTokenId,
                    liquidity: remainingLiquidity,
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp + 3600
                })
            );
        }
        
        // 最后收集所有费用
        console.log("Collecting final fees...");
        positionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: createdTokenId,
                recipient: deployer,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        
        // 销毁位置
        console.log("Burning position...");
        positionManager.burn(createdTokenId);
        
        console.log("=== Position Burned Successfully ===");
        console.log("TokenId burned:");
        console.logUint(createdTokenId);
    }
    
    // 仅添加流动性
    function runMint() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable testTokenAddress = payable(vm.envAddress("TEST_TOKEN_ADDRESS"));
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        address payable factoryAddress = payable(vm.envAddress("FACTORY_ADDRESS"));
        
        // 获取合约实例
        IUniswapV3Factory factory = IUniswapV3Factory(factoryAddress);
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        // 确保有足够的授权
        _ensureAllowances(deployer, wethAddress, testTokenAddress, positionManagerAddress);
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 确保池存在并已初始化
        address poolAddress = factory.getPool(wethAddress, testTokenAddress, 3000);
        if (poolAddress == address(0)) {
            poolAddress = factory.createPool(wethAddress, testTokenAddress, 3000);
        }
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        
        // 检查池是否已初始化
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
        if (sqrtPriceX96 == 0) {
            pool.initialize(1000000000000000000000000); // 1e24
        }
        
        // 添加流动性
        _addLiquidity(deployer, positionManager, wethAddress, testTokenAddress);
        
        // 停止广播
        vm.stopBroadcast();
    }
    
    // 仅增加流动性
    function runIncreaseLiquidity() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        
        // 获取合约实例
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        // 查找可用的 tokenId (这里使用 2，因为我们已经创建了 tokenId 1 和 2)
        createdTokenId = 2;
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 增加流动性
        _increaseLiquidity(deployer, positionManager, address(0), address(0));
        
        // 停止广播
        vm.stopBroadcast();
    }
    
    // 仅收集费用
    function runCollectFees() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        
        // 获取合约实例
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        // 查找可用的 tokenId (这里使用 2，因为我们已经创建了 tokenId 1 和 2)
        createdTokenId = 2;
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 收集费用
        _collectFees(deployer, positionManager);
        
        // 停止广播
        vm.stopBroadcast();
    }
    
    // 仅减少流动性
    function runDecreaseLiquidity() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        
        // 获取合约实例
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        // 查找可用的 tokenId (这里使用 2，因为我们已经创建了 tokenId 1 和 2)
        createdTokenId = 2;
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 减少流动性
        _decreaseLiquidity(deployer, positionManager);
        
        // 停止广播
        vm.stopBroadcast();
    }
    
    // 仅销毁位置
    function runBurnPosition() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        
        // 获取合约实例
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        // 查找可用的 tokenId (这里使用 2，因为我们已经创建了 tokenId 1 和 2)
        createdTokenId = 2;
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 销毁位置
        _burnPosition(deployer, positionManager);
        
        // 停止广播
        vm.stopBroadcast();
    }
    
} 