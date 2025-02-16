// SPDX-License-Identifier: BSL
pragma solidity 0.7.6;
//Used by SwapRouter.
pragma abicoder v2;

import { SwapRouter } from "@uniswap/v3-periphery/contracts/SwapRouter.sol";

contract SwapRouterFoundry is SwapRouter {

    constructor(address _factory, address _WETH9) SwapRouter(_factory,_WETH9) {}

}
