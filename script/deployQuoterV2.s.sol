// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "forge-std/Script.sol";
import { QuoterV2 } from "../lib/v3-periphery/contracts/lens/QuoterV2.sol";
import { IQuoterV2 } from "../lib/v3-periphery/contracts/interfaces/IQuoterV2.sol";

contract DeployQuoterV2 is Script {
    
    function run() public {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        
        // 从环境变量读取合约地址
        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");
        address wethAddress = vm.envAddress("WETH_ADDRESS");
        
        console.log("=== Deploy QuoterV2 ===");
        console.log("Deployer address:", deployer);
        console.log("Factory address:", factoryAddress);
        console.log("WETH address:", wethAddress);
        
        // 开始部署
        vm.startBroadcast(deployer);
        
        // 部署 QuoterV2
        QuoterV2 quoterV2 = new QuoterV2(factoryAddress, wethAddress);
        
        vm.stopBroadcast();
        
        // 输出部署结果
        console.log("=== Deployment Result ===");
        console.log("QuoterV2 deployed successfully!");
        console.log("QuoterV2 contract address:", address(quoterV2));
        
        // 验证部署
        console.log("=== Contract Verification ===");
        console.log("Factory from QuoterV2:", quoterV2.factory());
        console.log("WETH9 from QuoterV2:", quoterV2.WETH9());
        
        // 输出部署信息
        console.log("=== Deployment Summary ===");
        console.log("QuoterV2 deployed at:", address(quoterV2));
        console.log("Factory:", factoryAddress);
        console.log("WETH9:", wethAddress);
        console.log("Deployer:", deployer);
        console.log("=== End Deployment Summary ===");
    }
    
    // 验证 QuoterV2 部署
    function verifyQuoterV2() public view {
        address quoterV2Address = vm.envAddress("QUOTER_V2_ADDRESS");
        
        if (quoterV2Address == address(0)) {
            console.log("Error: QUOTER_V2_ADDRESS not set in environment variables");
            return;
        }
        
        QuoterV2 quoterV2 = QuoterV2(quoterV2Address);
        
        console.log("=== QuoterV2 Verification ===");
        console.log("QuoterV2 address:", quoterV2Address);
        console.log("Factory:", quoterV2.factory());
        console.log("WETH9:", quoterV2.WETH9());
        
        // 检查合约代码
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(quoterV2Address)
        }
        
        if (codeSize > 0) {
            console.log("Contract code size:", codeSize, "bytes");
            console.log("Verification: SUCCESS");
        } else {
            console.log("Verification: FAILED - No contract code found");
        }
    }
    
    // 测试 QuoterV2 功能
    function testQuoterV2() public {
        address quoterV2Address = vm.envAddress("QUOTER_V2_ADDRESS");
        address wethAddress = vm.envAddress("WETH_ADDRESS");
        address testTokenAddress = vm.envAddress("PQUSD_ADDRESS");
        
        if (quoterV2Address == address(0)) {
            console.log("Error: QUOTER_V2_ADDRESS not set in environment variables");
            return;
        }
        
        QuoterV2 quoterV2 = QuoterV2(quoterV2Address);
        
        console.log("=== Test QuoterV2 ===");
        console.log("Testing quote for WETH -> PQUSD swap");
        console.log("Amount in: 1 ETH (1000000000000000000 wei)");
        console.log("Fee tier: 3000 (0.3%)");
        
        try quoterV2.quoteExactInputSingle(
            IQuoterV2.QuoteExactInputSingleParams({
                tokenIn: wethAddress,
                tokenOut: testTokenAddress,
                amountIn: 1000000000000000000, // 1 ETH
                fee: 3000,
                sqrtPriceLimitX96: 0
            })
        ) returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        ) {
            console.log("=== Quote Result ===");
            console.log("Quote successful!");
            console.log("Amount out (wei):");
            console.logUint(amountOut);
            console.log("Amount out (PQUSD):");
            console.logUint(amountOut / 10**18);
            console.log("Sqrt price after:");
            console.logUint(uint256(sqrtPriceX96After));
            console.log("Initialized ticks crossed:");
            console.logUint(uint256(initializedTicksCrossed));
            console.log("Gas estimate:");
            console.logUint(gasEstimate);
        } catch Error(string memory reason) {
            console.log("=== Quote Failed ===");
            console.log("Quote failed with reason:", reason);
        } catch {
            console.log("=== Quote Failed ===");
            console.log("Quote failed with unknown error");
        }
    }
} 