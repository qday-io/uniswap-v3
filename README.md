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

Inside file:

lib/v3-core/contracts/UniswapV3Factory.sol:UniswapV3Factory

add the following line to the contract:

```solidity
bytes32 public constant POOL_INIT_CODE_HASH = keccak256(abi.encodePacked(type(UniswapV3Pool).creationCode));
```

this will be used later updating: 
```
-SwapRouter 
-NonfungibleTokenPositionDescriptor
-NonfungiblePositionManager
```
which uses library PoolAddress with CREATE2 to compute pool contract addresses:

https://github.com/uniswap/v3-periphery/blob/main/contracts/libraries/PoolAddress.sol#L33-L47

reference: 

https://ethereum.stackexchange.com/a/156409

Script:

```shell
forge create lib/v3-core/contracts/UniswapV3Factory.sol:UniswapV3Factory  \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--broadcast \
--verify 
```

### Step 2: Deploy SwapRouter 

Inside file:

lib/v3-periphery/contracts/libraries/PoolAddress.sol

go to:

https://github.com/uniswap/v3-periphery/blob/main/contracts/libraries/PoolAddress.sol#L6

then modify POOL_INIT_CODE_HASH to be the value you read from UniswapV3Factory after it was deployed:

```solidity
bytes32 internal constant POOL_INIT_CODE_HASH =  <UniswapV3Factory_POOL_INIT_CODE_HASH>;
```

Note: swaps will fail if POOL_INIT_CODE_HASH is not set correctly.

```shell
forge create lib/v3-periphery/contracts/SwapRouter.sol:SwapRouter \
--constructor-args-path src/deployConstructor/SwapRouter.txt \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--broadcast \
--verify 
```

### Step 3: Deploy NFTDescriptor

```shell
forge create lib/v3-periphery/contracts/libraries/NFTDescriptor.sol:NFTDescriptor  \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--broadcast \
--verify 
```

### Step 4: Deploy NonfungibleTokenPositionDescriptor

Use the --libraries flag in forge to link library NFTDescriptor to NonfungibleTokenPositionDescriptor

Example:

https://github.com/foundry-rs/foundry/issues/4587#issuecomment-1522159970

Inside file:

lib/v3-periphery/contracts/libraries/PoolAddress.sol

go to:

https://github.com/uniswap/v3-periphery/blob/main/contracts/libraries/PoolAddress.sol#L6

then modify POOL_INIT_CODE_HASH to be the value you read from UniswapV3Factory after it was deployed:

```solidity
bytes32 internal constant POOL_INIT_CODE_HASH =  <UniswapV3Factory_POOL_INIT_CODE_HASH>;
```

Note: adding liquidity will fail if POOL_INIT_CODE_HASH is not set correctly.

Script:

```shell
forge create lib/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol:NonfungibleTokenPositionDescriptor  \
--constructor-args-path src/deployConstructor/NonfungibleTokenPositionDescriptor.txt \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--broadcast \
--libraries lib/v3-periphery/contracts/libraries/NFTDescriptor.sol:NFTDescriptor:<contract_address> \
--verify 
```

### Step 5: Deploy NonfungiblePositionManager

Inside file:

lib/v3-periphery/contracts/libraries/PoolAddress.sol

go to:

https://github.com/uniswap/v3-periphery/blob/main/contracts/libraries/PoolAddress.sol#L6

then modify POOL_INIT_CODE_HASH to be the value you read from UniswapV3Factory after it was deployed:

```solidity
bytes32 internal constant POOL_INIT_CODE_HASH =  <UniswapV3Factory_POOL_INIT_CODE_HASH>;
```

Note: adding liquidity will fail if POOL_INIT_CODE_HASH is not set correctly.

Script:

```shell
forge create lib/v3-periphery/contracts/NonfungiblePositionManager.sol:NonfungiblePositionManager  \
--constructor-args-path src/deployConstructor/NonfungiblePositionManager.txt \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--broadcast \
--verify 
```

## Deployments 

### Base Sepolia

#### UniswapV3Factory

https://sepolia.basescan.org/address/0x25c1c9245098606091e74a6f07063e3ff50524e2#code

#### SwapRouter

https://sepolia.basescan.org/address/0xe0f5dfde6cc9770e2e45d91832cae8d4fee20526#code

#### NFTDescriptor

https://sepolia.basescan.org/address/0x6b0c2530ec1c8c4a56e2cfc6c4c2ecf5af0ea267#code

#### NonfungibleTokenPositionDescriptor

https://sepolia.basescan.org/address/0xc0135dfcf073d065fa07b499e32767e2ab3e2350#code

#### NonfungiblePositionManager

https://sepolia.basescan.org/address/0xc0135dfcf073d065fa07b499e32767e2ab3e2350#code
 
<!-- Note 1: Modify 

lib/v3-periphery/contracts/libraries/NFTDescriptor.sol

from library to contract to deploy. -->

<!-- Note 2: Contract

lib/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol
 
depends on the archived solidity-lib library which is already setup. -->

