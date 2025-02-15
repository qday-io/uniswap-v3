// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import { UniswapV3Factory } from "v3-core/contracts/UniswapV3Factory.sol";
// import { NonfungiblePositionManager } from "v3-periphery/contracts/NonfungiblePositionManager.sol";
// import { SwapRouter } from "v3-periphery/contracts/SwapRouter.sol";
// import { TickLens } from "@uniswap/v3-periphery/contracts/lenses/TickLens.sol";
// import { TickLens } from "@uniswap/v3-periphery/contracts/lenses/TickLens.sol";

contract DeployUniswap {

    UniswapV3Factory public factory;
    // NonfungiblePositionManager public positionManager;
    // SwapRouter public swapRouter;
    
    // TickLens public tickLens;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deploy() public {
        require(msg.sender == owner, "Only owner can deploy");

        // Deploy Uniswap V3 core contracts

        factory = new UniswapV3Factory();
        // positionManager = new NonfungiblePositionManager(address(factory));
        // swapRouter = new SwapRouter(address(factory));
        // tickLens = new TickLens(address(factory));


        // Now you can initialize the contracts or deploy other dependencies
    }
}
