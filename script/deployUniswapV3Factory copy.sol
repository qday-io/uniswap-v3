// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import { UniswapV3Factory } from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";

contract DeployUniswap {

    UniswapV3Factory public factory;

    function deploy() public {
        factory = new UniswapV3Factory();
    }
}
