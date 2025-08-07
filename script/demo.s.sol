// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "forge-std/Script.sol";

contract WETHDeposit is Script {
    
    function run() public {
        console.log("Hello World");
        string memory name = "John";
        console.log("name:",name);
        uint128 a = 1;
        uint128 b = 2;
        uint128 c = a + b;
        // console.log("c:",c);
        console.logUint(c);

        uint256 d=1;
        uint256 e=2;
        uint256 f=d+e;
        console.logUint(f);

    
    }

}