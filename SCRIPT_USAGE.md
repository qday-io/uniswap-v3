# 自动化部署脚本使用说明

## 脚本概述

`deploy_step_by_step.sh` 是一个自动化部署脚本，完全按照 [MarcusWentz 的 Uniswap V3 Foundry 部署项目](https://github.com/MarcusWentz/uniswapV3_foundry_deployment/blob/main/README.md) 的方法进行部署。

## 脚本功能

### ✅ 自动化功能

1. **环境检查** - 验证必要的环境变量
2. **.env 文件支持** - 自动读取 .env 文件中的环境变量
3. **项目编译** - 自动编译所有合约
4. **逐步部署** - 按照正确的顺序部署所有合约
5. **配置更新** - 自动更新构造函数参数和 POOL_INIT_CODE_HASH
6. **部署验证** - 验证所有合约部署是否成功
7. **摘要生成** - 自动生成部署摘要文档

### 🔧 部署步骤

脚本会自动执行以下 9 个步骤：

1. **部署 UniswapV3FactoryFoundry**
2. **获取 POOL_INIT_CODE_HASH**
3. **更新 PoolAddress.sol**
4. **更新 SwapRouter 构造函数参数**
5. **部署 SwapRouterFoundry**
6. **部署 NFTDescriptor**
7. **部署 NonfungibleTokenPositionDescriptorFoundry**
8. **更新 NonfungiblePositionManager 构造函数参数**
9. **部署 NonfungiblePositionManagerFoundry**

## 使用方法

### 方法 1: 使用 .env 文件（推荐）

#### 1. 创建 .env 文件

复制示例文件并填入您的实际值：

```bash
cp env.example .env
```

编辑 `.env` 文件：

```bash
# 私钥 (必填)
PRIVATE_KEY=your_private_key_here

# RPC URL (可选，默认为本地 Anvil)
RPC_URL=http://localhost:8545

# 生产环境示例
# RPC_URL=https://sepolia.base.org
```

#### 2. 启动 Anvil 节点（本地测试）

```bash
anvil
```

#### 3. 运行部署脚本

```bash
./deploy_step_by_step.sh
```

### 方法 2: 使用环境变量

```bash
# 设置环境变量
export PRIVATE_KEY=your_private_key_here
export RPC_URL=http://localhost:8545

# 运行脚本
./deploy_step_by_step.sh
```

## .env 文件配置

### 必需变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `PRIVATE_KEY` | 部署者私钥 | `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80` |

### 可选变量

| 变量名 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `RPC_URL` | RPC 节点地址 | `http://localhost:8545` | `https://sepolia.base.org` |
| `ETHERSCAN_API_KEY` | Etherscan API Key | 无 | `your_api_key_here` |
| `CHAIN_ID` | 链 ID | 自动检测 | `84532` |
| `WETH_ADDRESS` | WETH 合约地址 | `0x4200000000000000000000000000000000000006` | `0x...` |

## 输出示例

```
🚀 开始 Uniswap V3 Foundry 逐步部署...

[INFO] 加载 .env 文件...
[SUCCESS] .env 文件加载成功
[INFO] 环境信息:
  RPC URL: http://localhost:8545
  部署者地址: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

[INFO] 编译项目...
[SUCCESS] 编译成功

[INFO] 步骤 1: 部署 UniswapV3FactoryFoundry
[SUCCESS] UniswapV3FactoryFoundry 部署成功
  地址: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
  交易哈希: 0xbb5befa9b1a9b7b6c42c5f9516fd4d2ea57a32928ba859e24d5df31582e2f8c7

...

[SUCCESS] 🎉 Uniswap V3 Foundry 部署完成！

📋 部署摘要:
  Factory: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
  SwapRouter: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
  NFTDescriptor: 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
  NonfungibleTokenPositionDescriptor: 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
  NonfungiblePositionManager: 0x0165878A594ca255338adfa4d48449f69242Eb8F

📄 详细摘要已保存到: deployment_summary.md
```

## 生成的文件

### 1. 部署摘要 (`deployment_summary.md`)

包含完整的部署信息：
- 部署时间
- 环境信息
- 所有合约地址
- 关键配置
- 交易哈希
- 验证结果

### 2. 备份文件

脚本会自动备份修改的文件：
- `lib/v3-periphery/contracts/libraries/PoolAddress.sol.backup`
- `src/deployConstructor/SwapRouter.txt.backup`
- `src/deployConstructor/NonfungiblePositionManager.txt.backup`

## 安全注意事项

### .env 文件安全

1. **不要提交 .env 文件**
   ```bash
   # 确保 .env 在 .gitignore 中
   echo ".env" >> .gitignore
   ```

2. **使用示例文件**
   ```bash
   # 复制示例文件
   cp env.example .env
   # 编辑 .env 文件
   nano .env
   ```

3. **私钥安全**
   - 不要在代码中硬编码私钥
   - 使用环境变量或 .env 文件
   - 生产环境使用安全的密钥管理

## 错误处理

### 常见错误及解决方案

1. **找不到 .env 文件**
   ```bash
   [WARNING] 未找到 .env 文件，将使用环境变量
   ```
   - 创建 .env 文件：`cp env.example .env`
   - 或使用环境变量：`export PRIVATE_KEY=your_key`

2. **私钥未设置**
   ```bash
   [ERROR] 请设置 PRIVATE_KEY 环境变量
   ```
   - 在 .env 文件中设置 `PRIVATE_KEY=your_private_key`
   - 或使用环境变量：`export PRIVATE_KEY=your_private_key`

3. **编译失败**
   ```bash
   [ERROR] 编译失败
   ```
   - 检查所有依赖是否正确安装
   - 运行 `forge build` 查看详细错误

4. **部署失败**
   ```bash
   [ERROR] UniswapV3FactoryFoundry 部署失败
   ```
   - 检查私钥是否正确
   - 检查 RPC URL 是否可访问
   - 确保账户有足够的 ETH

## 网络配置示例

### 本地测试
```bash
# .env 文件
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://localhost:8545
```

### Base Sepolia 测试网
```bash
# .env 文件
PRIVATE_KEY=your_private_key_here
RPC_URL=https://sepolia.base.org
ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

### 其他网络
```bash
# .env 文件
PRIVATE_KEY=your_private_key_here
RPC_URL=https://your_rpc_url
CHAIN_ID=your_chain_id
WETH_ADDRESS=your_weth_address
```

## 故障排除

### 如果脚本中断

1. **检查日志** - 查看最后一步的输出
2. **手动继续** - 从失败的步骤开始手动执行
3. **恢复备份** - 使用 `.backup` 文件恢复原始配置

### 重新部署

如果需要重新部署：
```bash
# 清理之前的部署
rm -f deployment_summary.md

# 恢复备份文件（如果需要）
cp lib/v3-periphery/contracts/libraries/PoolAddress.sol.backup lib/v3-periphery/contracts/libraries/PoolAddress.sol
cp src/deployConstructor/SwapRouter.txt.backup src/deployConstructor/SwapRouter.txt
cp src/deployConstructor/NonfungiblePositionManager.txt.backup src/deployConstructor/NonfungiblePositionManager.txt

# 重新运行脚本
./deploy_step_by_step.sh
```

## 脚本优势

1. **完全自动化** - 无需手动执行每个步骤
2. **环境变量支持** - 支持 .env 文件和命令行环境变量
3. **错误处理** - 遇到错误时自动停止并显示详细信息
4. **配置管理** - 自动更新所有必要的配置文件
5. **验证机制** - 部署后自动验证合约功能
6. **文档生成** - 自动生成详细的部署摘要
7. **备份机制** - 自动备份修改的文件

---

*此脚本基于 MarcusWentz 的原始项目方法，确保部署的准确性和可靠性。* 