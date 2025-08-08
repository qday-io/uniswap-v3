// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PQUSD is ERC20 {
    constructor() ERC20("PQ USD", "PQUSD") {
        _mint(msg.sender, 1000000 * 10**decimals()); // 铸造 1,000,000 个代币
    }
} 