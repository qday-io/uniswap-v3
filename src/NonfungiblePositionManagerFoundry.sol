// SPDX-License-Identifier: BSL
pragma solidity 0.7.6;
//Used by NonfungiblePositionManager.
pragma abicoder v2;

import { NonfungiblePositionManager } from "@uniswap/v3-periphery/contracts/NonfungiblePositionManager.sol";

contract NonfungiblePositionManagerFoundry is NonfungiblePositionManager {

    // WETH in butes32 is:
    // 0x5745544800000000000000000000000000000000000000000000000000000000
    constructor(address factory, address weth9Address, address nftPositionDescriptor) NonfungiblePositionManager(factory,weth9Address,nftPositionDescriptor) {}

}
