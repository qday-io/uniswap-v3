// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "forge-std/Script.sol";
import { ISwapRouter } from "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { INonfungiblePositionManager } from "../lib/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import { IUniswapV3Factory } from "../lib/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { IUniswapV3Pool } from "../lib/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { IERC20 } from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CompleteFlowSimple is Script {
    function run() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address payable wethAddress = payable(vm.envAddress("WETH_ADDRESS"));
        address payable testTokenAddress = payable(vm.envAddress("TEST_TOKEN_ADDRESS"));
        address payable swapRouterAddress = payable(vm.envAddress("SWAP_ROUTER_ADDRESS"));
        address payable positionManagerAddress = payable(vm.envAddress("POSITION_MANAGER_ADDRESS"));
        address payable factoryAddress = payable(vm.envAddress("FACTORY_ADDRESS"));
        
        // 获取合约实例
        IUniswapV3Factory factory = IUniswapV3Factory(factoryAddress);
        INonfungiblePositionManager positionManager = INonfungiblePositionManager(positionManagerAddress);
        ISwapRouter swapRouter = ISwapRouter(swapRouterAddress);
        
        // Step 1: 启用手续费等级 (已启用，跳过)
        // factory.enableFeeAmount(3000, 60);
        
        // Step 2: 创建池 (检查是否存在，不存在则创建)
        address poolAddress = factory.getPool(wethAddress, testTokenAddress, 3000);
        if (poolAddress == address(0)) {
            // 池不存在，创建新池
            poolAddress = factory.createPool(wethAddress, testTokenAddress, 3000);
        }
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        
        // Step 3: 初始化池价格 (检查是否已初始化，未初始化则初始化)
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
        if (sqrtPriceX96 == 0) {
            // 池未初始化，进行初始化
            pool.initialize(1000000000000000000000000); // 1e24
        }
        
        // 校验 Step 4 之前的条件 - Approve
        require(IERC20(wethAddress).allowance(deployer, positionManagerAddress) >= 100000000000000000, "WETH allowance insufficient for mint");
        require(IERC20(testTokenAddress).allowance(deployer, positionManagerAddress) >= 100000000000000000000, "TestToken allowance insufficient for mint");
        require(IERC20(wethAddress).allowance(deployer, swapRouterAddress) >= 10000000000000000, "WETH allowance insufficient for swap");
        
        // Step 4: 添加 LP 流动性
        vm.prank(deployer);
        positionManager.mint(
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
                deadline: block.timestamp + 300
            })
        );
        
        // 校验 Step 5 之前的条件 - Approve
        require(IERC20(wethAddress).allowance(deployer, swapRouterAddress) >= 10000000000000000, "WETH allowance insufficient for swap");
        
        // Step 5: 执行用户 swap
        vm.prank(deployer);
        swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: wethAddress,
                tokenOut: testTokenAddress,
                fee: 3000,
                recipient: deployer,
                deadline: block.timestamp + 300,
                amountIn: 10000000000000000, // 0.01 ETH
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            })
        );
        
        // Step 6: LP 提现 (简化版本)
        // 注意：完整的 LP 提现需要先获取 tokenId，这里简化处理
    }
} 