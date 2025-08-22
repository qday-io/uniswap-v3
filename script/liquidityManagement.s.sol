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
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        address payable factoryAddress = payable(vm.envAddress("FACTORY_ADDRESS"));
        
        // 获取合约实例
        IUniswapV3Factory factory = IUniswapV3Factory(factoryAddress);
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        // 确保有足够的授权
        _ensureAllowances(deployer, wethAddress, pqusdAddress, positionManagerAddress);
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 确保池存在并已初始化
        address poolAddress = factory.getPool(wethAddress, pqusdAddress, 3000);
        if (poolAddress == address(0)) {
            poolAddress = factory.createPool(wethAddress, pqusdAddress, 3000);
        }
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        
        // 检查池是否已初始化
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
        if (sqrtPriceX96 == 0) {
            pool.initialize(1000000000000000000000000); // 1e24
        }
        
        // 执行流动性管理操作
        _addLiquidity(deployer, positionManager, wethAddress, pqusdAddress);
        _increaseLiquidity(deployer, positionManager, wethAddress, pqusdAddress);
        // _collectFees(deployer, positionManager);
        // _decreaseLiquidity(deployer, positionManager);
        // _burnPosition(deployer, positionManager);
        
        // 停止广播
        vm.stopBroadcast();
    }
    
    function _ensureAllowances(
        address deployer,
        address wethAddress,
        address pqusdAddress,
        address positionManagerAddress
    ) internal {
        // 检查并设置 WETH 授权
        uint256 wethAllowance = IERC20(wethAddress).allowance(deployer, positionManagerAddress);
        if (wethAllowance < 1000000000000000000) { // 1 ETH
            IERC20(wethAddress).approve(positionManagerAddress, type(uint256).max);
        }
        
        // 检查并设置 PQUSD 授权
        uint256 pqusdAllowance = IERC20(pqusdAddress).allowance(deployer, positionManagerAddress);
        if (pqusdAllowance < 1000000000000000000000) { // 1000 tokens
            IERC20(pqusdAddress).approve(positionManagerAddress, type(uint256).max);
        }
    }
    
    function _addLiquidity(
        address deployer,
        INonfungiblePositionManager positionManager,
        address wethAddress,
        address pqusdAddress
    ) internal {
        console.log("=== Add Liquidity ===");
        
        // 获取当前余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(deployer);
        uint256 pqusdBalance = IERC20(pqusdAddress).balanceOf(deployer);
        
        console.log("Balance before adding liquidity:");
        console.log("  WETH (wei):");
        console.logUint(wethBalance);
        console.log("  WETH (ETH):");
        console.logUint(wethBalance / 10**18);
        console.log("  PQUSD (wei):");
        console.logUint(pqusdBalance);
        console.log("  PQUSD (tokens):");
        console.logUint(pqusdBalance / 10**18);
        
        // 创建流动性位置
        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: wethAddress < pqusdAddress ? wethAddress : pqusdAddress,
                token1: wethAddress < pqusdAddress ? pqusdAddress : wethAddress,
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
        
        // 输出 tokenId 信息，供脚本捕获并写入 .env 文件
        console.log("=== TOKEN_ID_FOR_ENV ===");
        console.log("CREATED_TOKEN_ID=");
        console.logUint(tokenId);
        console.log("=== END_TOKEN_ID_FOR_ENV ===");
        
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
        uint256 newPqusdBalance = IERC20(pqusdAddress).balanceOf(deployer);
        
        console.log("=== Balance After Adding Liquidity ===");
        console.log("WETH (wei):");
        console.logUint(newWethBalance);
        console.log("WETH (ETH):");
        console.logUint(newWethBalance / 10**18);
        console.log("PQUSD (wei):");
        console.logUint(newPqusdBalance);
        console.log("PQUSD (tokens):");
        console.logUint(newPqusdBalance / 10**18);
        
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
    
    function _increaseLiquidity(
        address deployer,
        INonfungiblePositionManager positionManager,
        address wethAddress,
        address pqusdAddress
    ) internal {
        _increaseLiquidityWithTokenId(deployer, positionManager, wethAddress, pqusdAddress, createdTokenId);
    }
    
    function _increaseLiquidityWithTokenId(
        address deployer,
        INonfungiblePositionManager positionManager,
        address wethAddress,
        address pqusdAddress,
        uint256 tokenId
    ) internal {
        console.log("=== Increase Liquidity ===");
        
        // 获取增加流动性前的余额
        uint256 wethBalanceBefore = IERC20(wethAddress).balanceOf(deployer);
        uint256 pqusdBalanceBefore = IERC20(pqusdAddress).balanceOf(deployer);
        
        // 获取位置信息
        (,,,,,,,uint128 currentLiquidity,,,,) = positionManager.positions(tokenId);
        
        console.log("Current liquidity:");
        console.logUint(currentLiquidity);
        
        // 增加流动性
        (uint128 newLiquidity, uint256 amount0, uint256 amount1) = positionManager.increaseLiquidity(
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
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
        (,,,,,,,uint128 totalLiquidity,,,,) = positionManager.positions(tokenId);
        console.log("Total liquidity:");
        console.logUint(totalLiquidity);
        
        // 收集可能返回的代币
        _collectReturnedTokens(positionManager, tokenId, deployer);
        
        // 获取增加流动性并收集代币后的余额并显示变化
        _logBalanceChanges(deployer, wethAddress, pqusdAddress, wethBalanceBefore, pqusdBalanceBefore, "Increasing Liquidity");
    }
    
    function _collectFees(
        address deployer,
        INonfungiblePositionManager positionManager
    ) internal {
        _collectFeesWithTokenId(deployer, positionManager, createdTokenId);
    }
    
    function _collectFeesWithTokenId(
        address deployer,
        INonfungiblePositionManager positionManager,
        uint256 tokenId
    ) internal {
        console.log("=== Collect Fees ===");
        
        // 获取收集费用前的余额
        address wethAddress = vm.envAddress("WETH_ADDRESS");
        address pqusdAddress = vm.envAddress("PQUSD_ADDRESS");
        uint256 wethBalanceBefore = IERC20(wethAddress).balanceOf(deployer);
        uint256 pqusdBalanceBefore = IERC20(pqusdAddress).balanceOf(deployer);
        
        // 获取当前欠款
        (,,,,,,,,,,uint128 tokensOwed0,uint128 tokensOwed1) = positionManager.positions(tokenId);
        
        console.log("Current fees owed:");
        console.log("  Token0 owed (wei):");
        console.logUint(tokensOwed0);
        console.log("  Token1 owed (wei):");
        console.logUint(tokensOwed1);
        
        // 收集费用
        (uint256 amount0, uint256 amount1) = positionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
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
        
        // 获取收集费用后的余额
        uint256 wethBalanceAfter = IERC20(wethAddress).balanceOf(deployer);
        uint256 pqusdBalanceAfter = IERC20(pqusdAddress).balanceOf(deployer);
        
        console.log("=== Balance After Collecting Fees ===");
        console.log("  WETH (wei):");
        console.logUint(wethBalanceAfter);
        console.log("  WETH (ETH):");
        console.logUint(wethBalanceAfter / 1e18);
        console.log("  PQUSD (wei):");
        console.logUint(pqusdBalanceAfter);
        console.log("  PQUSD (tokens):");
        console.logUint(pqusdBalanceAfter / 1e18);
        
        console.log("=== Balance Changes ===");
        console.log("  WETH gained (wei):");
        console.logInt(int256(wethBalanceAfter) - int256(wethBalanceBefore));
        console.log("  WETH gained (ETH):");
        console.logInt((int256(wethBalanceAfter) - int256(wethBalanceBefore)) / 1e18);
        console.log("  PQUSD gained (wei):");
        console.logInt(int256(pqusdBalanceAfter) - int256(pqusdBalanceBefore));
        console.log("  PQUSD gained (tokens):");
        console.logInt((int256(pqusdBalanceAfter) - int256(pqusdBalanceBefore)) / 1e18);
    }
    
    function _decreaseLiquidity(
        address deployer,
        INonfungiblePositionManager positionManager
    ) internal {
        _decreaseLiquidityWithTokenId(deployer, positionManager, createdTokenId);
    }
    
    function _decreaseLiquidityWithTokenId(
        address deployer,
        INonfungiblePositionManager positionManager,
        uint256 tokenId
    ) internal {
        console.log("=== Decrease Liquidity ===");
        
        // 获取减少流动性前的余额
        address wethAddress = vm.envAddress("WETH_ADDRESS");
        address pqusdAddress = vm.envAddress("PQUSD_ADDRESS");
        uint256 wethBalanceBefore = IERC20(wethAddress).balanceOf(deployer);
        uint256 pqusdBalanceBefore = IERC20(pqusdAddress).balanceOf(deployer);
        
        // 获取当前流动性
        (,,,,,,,uint128 currentLiquidity,,,,) = positionManager.positions(tokenId);
        
        // 减少一半流动性
        uint128 decreaseAmount = currentLiquidity / 2;
        console.log("Decreasing liquidity by:");
        console.logUint(decreaseAmount);
        
        (uint256 amount0, uint256 amount1) = positionManager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: decreaseAmount,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp + 3600
            })
        );
        
        console.log("=== Liquidity Decreased Successfully ===");
        console.log("Token0 returned (wei):");
        console.logUint(amount0);
        console.log("Token1 used (wei):");
        console.logUint(amount1);
        
        // 显示减少后的流动性
        (,,,,,,,uint128 remainingLiquidity,,,,) = positionManager.positions(tokenId);
        console.log("Remaining liquidity:");
        console.logUint(remainingLiquidity);
        
        // 收集返回的代币
        _collectReturnedTokens(positionManager, tokenId, deployer);
        
        // 获取减少流动性并收集代币后的余额并显示变化
        _logBalanceChanges(deployer, wethAddress, pqusdAddress, wethBalanceBefore, pqusdBalanceBefore, "Decreasing Liquidity");
    }
    
    function _burnPosition(
        address deployer,
        INonfungiblePositionManager positionManager
    ) internal {
        _burnPositionWithTokenId(deployer, positionManager, createdTokenId);
    }
    
    function _burnPositionWithTokenId(
        address deployer,
        INonfungiblePositionManager positionManager,
        uint256 tokenId
    ) internal {
        console.log("=== Burn Position ===");
        console.log("TokenId to burn:");
        console.logUint(tokenId);
        
        // 首先收集所有剩余费用
        console.log("Collecting remaining fees...");
        positionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: deployer,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        
        // 减少所有剩余流动性
        (,,,,,,,uint128 remainingLiquidity,,,,) = positionManager.positions(tokenId);
        
        console.log("Remaining liquidity before burn:");
        console.logUint(remainingLiquidity);
        
        if (remainingLiquidity > 0) {
            console.log("Decreasing remaining liquidity...");
            positionManager.decreaseLiquidity(
                INonfungiblePositionManager.DecreaseLiquidityParams({
                    tokenId: tokenId,
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
                tokenId: tokenId,
                recipient: deployer,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
        
        // 销毁位置
        console.log("Burning position...");
        positionManager.burn(tokenId);
        
        console.log("=== Position Burned Successfully ===");
        console.log("TokenId burned:");
        console.logUint(tokenId);
    }
    
    // 仅添加流动性
    function runMint() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable pqusdAddress = payable(vm.envAddress("PQUSD_ADDRESS"));
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        address payable factoryAddress = payable(vm.envAddress("FACTORY_ADDRESS"));
        
        // 获取合约实例
        IUniswapV3Factory factory = IUniswapV3Factory(factoryAddress);
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 确保有足够的授权（在广播模式下执行）
        _ensureAllowances(deployer, wethAddress, pqusdAddress, positionManagerAddress);
        
        // 确保池存在并已初始化
        address poolAddress = factory.getPool(wethAddress, pqusdAddress, 3000);
        if (poolAddress == address(0)) {
            poolAddress = factory.createPool(wethAddress, pqusdAddress, 3000);
        }
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        
        // 检查池是否已初始化
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
        if (sqrtPriceX96 == 0) {
            pool.initialize(1000000000000000000000000); // 1e24
        }
        
        // 添加流动性
        _addLiquidity(deployer, positionManager, wethAddress, pqusdAddress);
        
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
        
        // 从环境变量读取 tokenId
        uint256 tokenId = vm.envUint("CREATED_TOKEN_ID");
        if (tokenId == 0) {
            console.log("Error: CREATED_TOKEN_ID not set in environment, please run mint first");
            return;
        }
        
        console.log("Using tokenId from env:", tokenId);
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 从环境变量读取代币地址
        address wethAddress = vm.envAddress("WETH_ADDRESS");
        address pqusdAddress = vm.envAddress("PQUSD_ADDRESS");
        
        // 确保有足够的授权
        _ensureAllowances(deployer, wethAddress, pqusdAddress, positionManagerAddress);
        
        // 增加流动性
        _increaseLiquidityWithTokenId(deployer, positionManager, wethAddress, pqusdAddress, tokenId);
        
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
        
        // 从环境变量读取 tokenId
        uint256 tokenId = vm.envUint("CREATED_TOKEN_ID");
        if (tokenId == 0) {
            console.log("Error: CREATED_TOKEN_ID not set in environment, please run mint first");
            return;
        }
        
        console.log("Using tokenId from env:", tokenId);
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 收集费用
        _collectFeesWithTokenId(deployer, positionManager, tokenId);
        
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
        
        // 从环境变量读取 tokenId
        uint256 tokenId = vm.envUint("CREATED_TOKEN_ID");
        if (tokenId == 0) {
            console.log("Error: CREATED_TOKEN_ID not set in environment, please run mint first");
            return;
        }
        
        console.log("Using tokenId from env:", tokenId);
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 减少流动性
        _decreaseLiquidityWithTokenId(deployer, positionManager, tokenId);
        
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
        
        // 从环境变量读取 tokenId
        uint256 tokenId = vm.envUint("CREATED_TOKEN_ID");
        if (tokenId == 0) {
            console.log("Error: CREATED_TOKEN_ID not set in environment, please run mint first");
            return;
        }
        
        console.log("Using tokenId from env:", tokenId);
        
        // 开始广播交易
        vm.startBroadcast(deployer);
        
        // 销毁位置
        _burnPositionWithTokenId(deployer, positionManager, tokenId);
        
        // 停止广播
        vm.stopBroadcast();
    }
    
    // 查询余额和流动性状态
    function runQueryBalance() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取代币地址
        address wethAddress = vm.envAddress("WETH_ADDRESS");
        address pqusdAddress = vm.envAddress("PQUSD_ADDRESS");
        
        console.log("=== Balance and Liquidity Status ===");
        console.log("User Address:");
        console.logAddress(deployer);
        
        // 查询代币余额
        uint256 wethBalance = IERC20(wethAddress).balanceOf(deployer);
        uint256 pqusdBalance = IERC20(pqusdAddress).balanceOf(deployer);
        
        console.log("=== Token Balances ===");
        console.log("WETH Balance:");
        console.log("  Wei:");
        console.logUint(wethBalance);
        console.log("  ETH:");
        console.logUint(wethBalance / 1e18);
        console.log("PQUSD Balance:");
        console.log("  Wei:");
        console.logUint(pqusdBalance);
        console.log("  Tokens:");
        console.logUint(pqusdBalance / 1e18);
        
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
    
    // 辅助函数：收集返回的代币
    function _collectReturnedTokens(
        INonfungiblePositionManager positionManager,
        uint256 tokenId,
        address deployer
    ) internal {
        console.log("Collecting returned tokens...");
        positionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: deployer,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
    }
    
    // 辅助函数：记录余额变化
    function _logBalanceChanges(
        address deployer,
        address wethAddress,
        address pqusdAddress,
        uint256 wethBalanceBefore,
        uint256 pqusdBalanceBefore,
        string memory operation
    ) internal {
        // 获取操作后的余额
        uint256 wethBalanceAfter = IERC20(wethAddress).balanceOf(deployer);
        uint256 pqusdBalanceAfter = IERC20(pqusdAddress).balanceOf(deployer);
        
        console.log("=== Balance After ", operation, " ===");
        console.log("  WETH (wei):");
        console.logUint(wethBalanceAfter);
        console.log("  WETH (ETH):");
        console.logUint(wethBalanceAfter / 1e18);
        console.log("  PQUSD (wei):");
        console.logUint(pqusdBalanceAfter);
        console.log("  PQUSD (tokens):");
        console.logUint(pqusdBalanceAfter / 1e18);
        
        console.log("=== Balance Changes ===");
        console.log("  WETH gained (wei):");
        console.logInt(int256(wethBalanceAfter) - int256(wethBalanceBefore));
        console.log("  WETH gained (ETH):");
        console.logInt((int256(wethBalanceAfter) - int256(wethBalanceBefore)) / 1e18);
        console.log("  PQUSD gained (wei):");
        console.logInt(int256(pqusdBalanceAfter) - int256(pqusdBalanceBefore));
        console.log("  PQUSD gained (tokens):");
        console.logInt((int256(pqusdBalanceAfter) - int256(pqusdBalanceBefore)) / 1e18);
    }
    
} 