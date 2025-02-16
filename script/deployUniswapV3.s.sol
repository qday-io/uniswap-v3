// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

// import { UniswapV3Factory } from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
// import { SwapRouter } from "@uniswap/v3-periphery/contracts/SwapRouter.sol";

// // // // // Keep NFTDescriptor as a library to avoid NonfungibleTokenPositionDescriptor compilation errors.
// // import { NFTDescriptor } from "@uniswap/v3-periphery/contracts/libraries/NFTDescriptor.sol";
// // // https://github.com/Uniswap/v3-periphery/issues/272
// // // https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/NFTDescriptor.sol

// import { NonfungibleTokenPositionDescriptor } from "@uniswap/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol";

// // Set Solidity compiler optimizations to 200 or 1000 to get around the stack too deep error with NonfungiblePositionManager.
// // foundry.toml
// // optimizer = true
// // optimizer_runs = 200
// // https://github.com/Uniswap/v3-periphery/issues/273
// import { NonfungiblePositionManager } from "@uniswap/v3-periphery/contracts/NonfungiblePositionManager.sol";

// contract deployUniswapV3 {

//     UniswapV3Factory public factory;
//     SwapRouter public swapRouter;

//     // // // Keep NFTDescriptor as a library to avoid NonfungibleTokenPositionDescriptor compilation errors.
//     // NFTDescriptor public nftDescriptor;

//     NonfungibleTokenPositionDescriptor public nftPositionDescriptor;
//     NonfungiblePositionManager public nftPositionManager;

//     function run() public {
//         deploy();
//     }

//     function deploy() public {

//         // Base Sepolia WETH address.
//         // https://sepolia.basescan.org/address/0x4200000000000000000000000000000000000006
//         address weth9Address = 0x4200000000000000000000000000000000000006;

//         factory = new UniswapV3Factory();
        
//         swapRouter = new SwapRouter(
//             address(factory),
//             weth9Address
//         );

//         // // // Keep NFTDescriptor as a library to avoid NonfungibleTokenPositionDescriptor compilation errors.
//         // nftDescriptor = new NFTDescriptor();

//         bytes32 nativeCurrencyLabelBytes = "WETH";

//         nftPositionDescriptor = new NonfungibleTokenPositionDescriptor(
//             weth9Address, 
//             nativeCurrencyLabelBytes
//         );

//         // address weth9Address = address(0);
//         // address factoryAddress = address(0);
//         // address tokenDescriptorAddress = address(0); // address(nftDescriptor)

//         nftPositionManager = new NonfungiblePositionManager(
//             address(factory), // factoryAddress,
//             weth9Address,
//             address(nftPositionDescriptor)
//         );

//     }
// }
