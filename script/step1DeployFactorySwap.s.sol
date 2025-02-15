// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import { UniswapV3Factory } from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import { SwapRouter } from "@uniswap/v3-periphery/contracts/SwapRouter.sol";

contract DeployUniswap {

    UniswapV3Factory public factory;
    SwapRouter public swapRouter;

    function deploy() public {
        
        address weth9Address = address(0);

        factory = new UniswapV3Factory();
        
        swapRouter = new SwapRouter(
            address(factory),
            weth9Address
        );

    }
}
