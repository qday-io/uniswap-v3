// SPDX-License-Identifier: BSL
pragma solidity 0.7.6;

import { NonfungibleTokenPositionDescriptor } from "@uniswap/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol";

contract NonfungibleTokenPositionDescriptorFoundry is NonfungibleTokenPositionDescriptor {

    constructor(address weth9Address, bytes32 nativeCurrencyLabelBytes) NonfungibleTokenPositionDescriptor(weth9Address,nativeCurrencyLabelBytes) {}

}

