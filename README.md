## Foundry

Based on:

https://www.youtube.com/watch?v=SeiaiiviEhM

https://github.com/MarcusWentz/uniswapV3_hardhat_deployment


### Install Uniswap V3 contracts directly

```shell
forge install https://github.com/Uniswap/v3-core --no-commit
forge install https://github.com/Uniswap/v3-periphery --no-commit
forge install https://github.com/Brechtpd/base64 --no-commit
forge install https://github.com/Uniswap/solidity-lib --no-commit
```

## Install Specific OpenZeppelin Version for Uniswap V3 with NPM

Uniswap V3 depends on an oudated version of OpenZeppelin defined in package.json:

https://github.com/Uniswap/v3-periphery/blob/main/package.json

which is added to the package.json in this project with:

```shell
npm install @openzeppelin/contracts@3.4.2-solc-0.7
```

then moved into Foundry path lib with these commands:

```shell
npm i
mkdir -p lib/openzeppelin-contracts
cp -r node_modules/@openzeppelin/contracts lib/openzeppelin-contracts/
```

## Scripts

```shell
forge script script/deployUniswapV3.s.sol:deployUniswapV3 \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--verify \
--broadcast
```

## Deploy Uniswap V3 With Forge Commands Directly 

### Step 1: Deploy UniswapV3Factory 

```shell
forge create src/UniswapV3FactoryFoundry.sol:UniswapV3FactoryFoundry  \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--broadcast \
--verify 
```

--constructor-args-path src/deployConstructor/UniswapV2Factory.txt \


<!-- Note 1: Modify 

lib/v3-periphery/contracts/libraries/NFTDescriptor.sol

from library to contract to deploy. -->

<!-- Note 2: Contract

lib/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol
 
depends on the archived solidity-lib library which is already setup. -->

