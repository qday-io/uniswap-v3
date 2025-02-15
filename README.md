## Foundry

### Install

```shell
forge install https://github.com/Uniswap/v3-core --no-commit
forge install https://github.com/Uniswap/v3-periphery --no-commit
forge install https://github.com/OpenZeppelin/openzeppelin-contracts --no-commit
```

:warning: 

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