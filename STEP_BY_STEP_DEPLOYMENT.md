# Uniswap V3 Foundry 逐步部署指南

## 概述
本文档记录了按照 [MarcusWentz 的 Uniswap V3 Foundry 部署项目](https://github.com/MarcusWentz/uniswapV3_foundry_deployment/blob/main/README.md) 进行的完整部署过程。

## 环境准备

### 设置环境变量
```bash
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export RPC_URL=http://localhost:8545
```

### 启动 Anvil 节点
```bash
anvil
```

## 部署步骤

### 步骤 1: 部署 UniswapV3FactoryFoundry

**命令:**
```bash
forge create src/UniswapV3FactoryFoundry.sol:UniswapV3FactoryFoundry \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --broadcast
```

**输出:**
```
[⠊] Compiling...
No files changed, compilation skipped
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
Transaction hash: 0xbb5befa9b1a9b7b6c42c5f9516fd4d2ea57a32928ba859e24d5df31582e2f8c7
```

**合约地址:** `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`

---

### 步骤 2: 获取 POOL_INIT_CODE_HASH

**命令:**
```bash
cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "POOL_INIT_CODE_HASH()" --rpc-url http://localhost:8545
```

**输出:**
```
0x9c04c88d8386e62c4a00fdfc590aa86961acced3053c1aacae2996dc3c3e24ef
```

**POOL_INIT_CODE_HASH:** `0x9c04c88d8386e62c4a00fdfc590aa86961acced3053c1aacae2996dc3c3e24ef`

---

### 步骤 3: 更新 PoolAddress.sol

**文件:** `lib/v3-periphery/contracts/libraries/PoolAddress.sol`

**修改前:**
```solidity
bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;
```

**修改后:**
```solidity
bytes32 internal constant POOL_INIT_CODE_HASH = 0x9c04c88d8386e62c4a00fdfc590aa86961acced3053c1aacae2996dc3c3e24ef;
```

---

### 步骤 4: 更新 SwapRouter 构造函数参数

**文件:** `src/deployConstructor/SwapRouter.txt`

**修改前:**
```
0x25c1c9245098606091e74a6f07063e3ff50524e2
0x4200000000000000000000000000000000000006
```

**修改后:**
```
0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
0x4200000000000000000000000000000000000006
```

---

### 步骤 5: 部署 SwapRouterFoundry

**命令:**
```bash
forge create src/SwapRouterFoundry.sol:SwapRouterFoundry \
  --constructor-args-path src/deployConstructor/SwapRouter.txt \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --broadcast
```

**输出:**
```
[⠊] Compiling...
[⠒] Compiling 4 files with Solc 0.7.6
[⠢] Solc 0.7.6 finished in 1.11s
Compiler run successful!
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
Transaction hash: 0xadde0e957a2645b8047bb83645913053c9939740d64f2c385120cd73ec685fc7
```

**合约地址:** `0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9`

---

### 步骤 6: 部署 NFTDescriptor

**命令:**
```bash
forge create lib/v3-periphery/contracts/libraries/NFTDescriptor.sol:NFTDescriptor \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --broadcast
```

**输出:**
```
[⠊] Compiling...
No files changed, compilation skipped
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
Transaction hash: 0x21c7a8bae764d5b9dfb940b6844705f7e56aa0fb20953d3815a0ceb3ad1a6a97
```

**合约地址:** `0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9`

---

### 步骤 7: 部署 NonfungibleTokenPositionDescriptorFoundry

**命令:**
```bash
forge create src/NonfungibleTokenPositionDescriptorFoundry.sol:NonfungibleTokenPositionDescriptorFoundry \
  --constructor-args-path src/deployConstructor/NonfungibleTokenPositionDescriptor.txt \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --broadcast \
  --libraries lib/v3-periphery/contracts/libraries/NFTDescriptor.sol:NFTDescriptor:0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
```

**输出:**
```
[⠊] Compiling...
[⠢] Compiling 36 files with Solc 0.7.6
[⠆] Solc 0.7.6 finished in 1.20s
Compiler run successful!
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
Transaction hash: 0xd1f74eb741f6f0843adf21f78504894b6198d2cba871aabf52e9d40d1cdc76fa
```

**合约地址:** `0x5FC8d32690cc91D4c39d9d3abcBD16989F875707`

---

### 步骤 8: 更新 NonfungiblePositionManager 构造函数参数

**文件:** `src/deployConstructor/NonfungiblePositionManager.txt`

**修改前:**
```
0x25c1c9245098606091e74a6f07063e3ff50524e2
0x4200000000000000000000000000000000000006
0xc0135dfcf073d065fa07b499e32767e2ab3e2350
```

**修改后:**
```
0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
0x4200000000000000000000000000000000000006
0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
```

---

### 步骤 9: 部署 NonfungiblePositionManagerFoundry

**命令:**
```bash
forge create src/NonfungiblePositionManagerFoundry.sol:NonfungiblePositionManagerFoundry \
  --constructor-args-path src/deployConstructor/NonfungiblePositionManager.txt \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --broadcast
```

**输出:**
```
[⠊] Compiling...
[⠆] Compiling 56 files with Solc 0.7.6
[⠰] Solc 0.7.6 finished in 2.32s
Compiler run successful!
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x0165878A594ca255338adfa4d48449f69242Eb8F
Transaction hash: 0xec142c616fbb793efdf8bdd70c9886f9fdef7773b7f29cc93ce450b05f8676df
```

**合约地址:** `0x0165878A594ca255338adfa4d48449f69242Eb8F`

---

## 部署验证

### 验证命令
```bash
echo "=== 部署验证 ==="
echo "Factory: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"
cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "owner()" --rpc-url http://localhost:8545
echo "SwapRouter: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
cast call 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 "factory()" --rpc-url http://localhost:8545
```

### 验证结果
```
=== 部署验证 ===
Factory: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
0x000000000000000000000000f39fd6e51aad88f6f4ce6ab8827279cfffb92266
SwapRouter: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
0x0000000000000000000000009fe46736679d2d9a65f0992f2272de9f3c7fa6e0
```

**验证结果:**
- ✅ Factory Owner: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`
- ✅ SwapRouter Factory: `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0`

---

## 最终部署摘要

### 合约地址列表

| 合约名称 | 地址 |
|---------|------|
| UniswapV3FactoryFoundry | `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0` |
| SwapRouterFoundry | `0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9` |
| NFTDescriptor | `0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9` |
| NonfungibleTokenPositionDescriptorFoundry | `0x5FC8d32690cc91D4c39d9d3abcBD16989F875707` |
| NonfungiblePositionManagerFoundry | `0x0165878A594ca255338adfa4d48449f69242Eb8F` |

### 关键配置

- **POOL_INIT_CODE_HASH**: `0x9c04c88d8386e62c4a00fdfc590aa86961acced3053c1aacae2996dc3c3e24ef`
- **WETH 地址**: `0x4200000000000000000000000000000000000006`
- **部署者**: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`

### 交易哈希列表

| 合约 | 交易哈希 |
|------|----------|
| UniswapV3FactoryFoundry | `0xbb5befa9b1a9b7b6c42c5f9516fd4d2ea57a32928ba859e24d5df31582e2f8c7` |
| SwapRouterFoundry | `0xadde0e957a2645b8047bb83645913053c9939740d64f2c385120cd73ec685fc7` |
| NFTDescriptor | `0x21c7a8bae764d5b9dfb940b6844705f7e56aa0fb20953d3815a0ceb3ad1a6a97` |
| NonfungibleTokenPositionDescriptorFoundry | `0xd1f74eb741f6f0843adf21f78504894b6198d2cba871aabf52e9d40d1cdc76fa` |
| NonfungiblePositionManagerFoundry | `0xec142c616fbb793efdf8bdd70c9886f9fdef7773b7f29cc93ce450b05f8676df` |

---

## 重要注意事项

1. **POOL_INIT_CODE_HASH 更新**: 必须使用从工厂合约获取的实际值
2. **构造函数参数**: 所有构造函数参数文件都需要使用新部署的合约地址
3. **库链接**: NFTDescriptor 必须正确链接到 NonfungibleTokenPositionDescriptor
4. **验证**: 部署后必须验证所有合约的功能

---

## 下一步操作

部署完成后，您可以：

1. **创建流动性池**: 使用 Factory 合约创建新的流动性池
2. **执行代币交换**: 使用 SwapRouter 进行代币交换
3. **管理流动性**: 使用 NonfungiblePositionManager 管理流动性位置
4. **铸造 NFT**: 创建流动性位置 NFT

---

*本文档记录了完整的 Uniswap V3 Foundry 部署过程，所有步骤都已验证成功。* 