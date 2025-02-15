## Foundry

### Install Uniswap V3 contracts directly

```shell
forge install https://github.com/Uniswap/v3-core --no-commit
forge install https://github.com/Uniswap/v3-periphery --no-commit
```


## Install

v3- pe depends on openzeppelin outdated version

https://github.com/Uniswap/v3-periphery/

```shell
npm install @openzeppelin/contracts@3.4.2-solc-0.7
```

setup with

```shell
npm i
mkdir -p lib/openzeppelin-contracts
cp -r node_modules/@openzeppelin/contracts lib/openzeppelin-contracts/
```


In:

lib/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol

modify the outdated file path for:

```solidity
import '@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol';
```

to be:

```solidity
import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';
```

also in:

lib/v3-periphery/contracts/base/SelfPermit.sol

modify the outdated file path for:

```solidity
import '@openzeppelin/contracts/drafts/IERC20Permit.sol';
```

update to be

```solidity
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol';
``` 
