// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import { UniswapV3Factory } from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import { SwapRouter } from "@uniswap/v3-periphery/contracts/SwapRouter.sol";

// NFTDescriptor modified from library to contract to deploy.
import { NFTDescriptor } from "@uniswap/v3-periphery/contracts/libraries/NFTDescriptor.sol";
// https://github.com/Uniswap/v3-periphery/issues/272
// https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/NFTDescriptor.sol

import { NonfungiblePositionManager } from "@uniswap/v3-periphery/contracts/NonfungiblePositionManager.sol";

contract DeployUniswap {

    UniswapV3Factory public factory;
    SwapRouter public swapRouter;
    // NFTDescriptor modified from library to contract to deploy.
    NFTDescriptor public nftDescriptor;
    NonfungiblePositionManager public positionManager;

    function deploy() public {

        address weth9Address = address(0);

        factory = new UniswapV3Factory();
        
        swapRouter = new SwapRouter(
            address(factory),
            weth9Address
        );

        // NFTDescriptor modified from library to contract to deploy.
        nftDescriptor = new NFTDescriptor();

        // address weth9Address = address(0);
        // address factoryAddress = address(0);
        address tokenDescriptorAddress = address(0);

        positionManager = new NonfungiblePositionManager(
            address(factory), // factoryAddress,
            weth9Address,
            tokenDescriptorAddress
        );

    }
}
