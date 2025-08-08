# Uniswap V3 Foundry 快速开始指南

## 🚀 快速部署

### 1. 准备环境

```bash
# 确保已安装 Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 克隆项目（如果还没有）
git clone <your-repo-url>
cd uniswapV3_foundry_deployment
```

### 2. 安装依赖

```bash
# 安装所有依赖
forge install
forge build
```

### 3. 配置环境变量

```bash
# 复制示例文件
cp env.example .env

# 编辑 .env 文件
nano .env
```

在 `.env` 文件中设置：

```bash
# 本地测试（使用 Anvil 默认私钥）
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://localhost:8545

# 生产环境
# PRIVATE_KEY=your_private_key_here
# RPC_URL=https://sepolia.base.org
```

### 4. 启动本地节点（可选）

```bash
# 启动 Anvil 节点
anvil
```

### 5. 部署 WETH 和 PQUSD

```bash
# 部署 WETH 和 PQUSD 合约
./deploy_weth_pqusd.sh
```

### 6. 运行完整部署脚本

```bash
# 一键部署 Uniswap V3
./deploy_step_by_step.sh
```

### 7. 部署 QuoterV2 合约

```bash
# 部署 QuoterV2 合约
./run_deploy_quoterV2.sh deploy

# 验证 QuoterV2 部署
./run_deploy_quoterV2.sh verify

# 测试 QuoterV2 功能
./run_deploy_quoterV2.sh test
```

## 📋 部署结果

部署完成后，您将看到：

```
🎉 Uniswap V3 Foundry 部署完成！

📋 部署摘要:
  Factory: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
  SwapRouter: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
  NFTDescriptor: 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
  NonfungibleTokenPositionDescriptor: 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
  NonfungiblePositionManager: 0x0165878A594ca255338adfa4d48449f69242Eb8F
  WETH: 0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5
  PQUSD: 0x1984973E205CFBc454C7092d3aD051B54aB6663e
  QuoterV2: 0x8b17423CFD1882e2493983DA0dA7FD72032C67A1

📄 详细摘要已保存到: deployment_summary.md
```

## 📄 .env 文件效果

部署完成后，您的 `.env` 文件将包含所有必要的合约地址：

### 部署前的 .env 文件
```bash
# 基础配置
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://localhost:8545

# 合约地址（部署前为空或占位符）
WETH_ADDRESS=0x1234567890123456789012345678901234567890
PQUSD_ADDRESS=0x1234567890123456789012345678901234567890
POSITION_MANAGER_ADDRESS=0x1234567890123456789012345678901234567890
FACTORY_ADDRESS=0x1234567890123456789012345678901234567890
SWAP_ROUTER_ADDRESS=0x1234567890123456789012345678901234567890
QUOTER_V2_ADDRESS=0x1234567890123456789012345678901234567890
```

### 部署后的 .env 文件
```bash
# 基础配置
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://localhost:8545

# 代币合约地址（由 deploy_weth_pqusd.sh 设置）
WETH_ADDRESS=0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5
PQUSD_ADDRESS=0x1984973E205CFBc454C7092d3aD051B54aB6663e

# Uniswap V3 核心合约地址（由 deploy_step_by_step.sh 设置）
FACTORY_ADDRESS=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
SWAP_ROUTER_ADDRESS=0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
POSITION_MANAGER_ADDRESS=0x0165878A594ca255338adfa4d48449f69242Eb8F
QUOTER_V2_ADDRESS=0x8b17423CFD1882e2493983DA0dA7FD72032C67A1

# 网络配置
CHAIN_ID=31337
```

### 环境变量的作用

每个环境变量都有特定的用途：

| 变量名 | 用途 | 设置脚本 |
|--------|------|----------|
| `WETH_ADDRESS` | WETH 代币合约地址 | `deploy_weth_pqusd.sh` |
| `PQUSD_ADDRESS` | PQUSD 代币合约地址 | `deploy_weth_pqusd.sh` |
| `FACTORY_ADDRESS` | Uniswap V3 工厂合约 | `deploy_step_by_step.sh` |
| `SWAP_ROUTER_ADDRESS` | 交换路由器合约 | `deploy_step_by_step.sh` |
| `POSITION_MANAGER_ADDRESS` | NFT 位置管理器 | `deploy_step_by_step.sh` |
| `QUOTER_V2_ADDRESS` | 报价合约 | `run_deploy_quoterV2.sh` |

### 验证 .env 文件

您可以使用以下命令验证 `.env` 文件是否正确设置：

```bash
# 加载环境变量
source .env

# 检查所有环境变量
echo "=== 环境变量检查 ==="
echo "WETH_ADDRESS: $WETH_ADDRESS"
echo "PQUSD_ADDRESS: $PQUSD_ADDRESS"
echo "FACTORY_ADDRESS: $FACTORY_ADDRESS"
echo "SWAP_ROUTER_ADDRESS: $SWAP_ROUTER_ADDRESS"
echo "POSITION_MANAGER_ADDRESS: $POSITION_MANAGER_ADDRESS"
echo "QUOTER_V2_ADDRESS: $QUOTER_V2_ADDRESS"

# 验证合约地址（检查是否有合约代码）
echo ""
echo "=== 合约验证 ==="
if [ ! -z "$WETH_ADDRESS" ] && [ "$WETH_ADDRESS" != "0x1234567890123456789012345678901234567890" ]; then
    echo "✅ WETH 合约已部署: $WETH_ADDRESS"
else
    echo "❌ WETH 合约未部署或地址无效"
fi

if [ ! -z "$PQUSD_ADDRESS" ] && [ "$PQUSD_ADDRESS" != "0x1234567890123456789012345678901234567890" ]; then
    echo "✅ PQUSD 合约已部署: $PQUSD_ADDRESS"
else
    echo "❌ PQUSD 合约未部署或地址无效"
fi

if [ ! -z "$FACTORY_ADDRESS" ] && [ "$FACTORY_ADDRESS" != "0x1234567890123456789012345678901234567890" ]; then
    echo "✅ Factory 合约已部署: $FACTORY_ADDRESS"
else
    echo "❌ Factory 合约未部署或地址无效"
fi

# 使用 cast 验证合约代码
echo ""
echo "=== 合约代码验证 ==="
if [ ! -z "$WETH_ADDRESS" ]; then
    WETH_CODE=$(cast code $WETH_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
    if [ "$WETH_CODE" != "0x" ] && [ ! -z "$WETH_CODE" ]; then
        echo "✅ WETH 合约代码存在"
    else
        echo "❌ WETH 合约代码不存在"
    fi
fi

if [ ! -z "$PQUSD_ADDRESS" ]; then
    PQUSD_CODE=$(cast code $PQUSD_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
    if [ "$PQUSD_CODE" != "0x" ] && [ ! -z "$PQUSD_CODE" ]; then
        echo "✅ PQUSD 合约代码存在"
    else
        echo "❌ PQUSD 合约代码不存在"
    fi
fi
```

### 验证示例

#### 部署前的验证结果
```bash
=== 环境变量检查 ===
WETH_ADDRESS: 0x1234567890123456789012345678901234567890
PQUSD_ADDRESS: 0x1234567890123456789012345678901234567890
FACTORY_ADDRESS: 0x1234567890123456789012345678901234567890

=== 合约验证 ===
❌ WETH 合约未部署或地址无效
❌ PQUSD 合约未部署或地址无效
❌ Factory 合约未部署或地址无效

=== 合约代码验证 ===
❌ WETH 合约代码不存在
❌ PQUSD 合约代码不存在
```

#### 部署后的验证结果
```bash
=== 环境变量检查 ===
WETH_ADDRESS: 0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5
PQUSD_ADDRESS: 0x1984973E205CFBc454C7092d3aD051B54aB6663e
FACTORY_ADDRESS: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
QUOTER_V2_ADDRESS: 0x8b17423CFD1882e2493983DA0dA7FD72032C67A1

=== 合约验证 ===
✅ WETH 合约已部署: 0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5
✅ PQUSD 合约已部署: 0x1984973E205CFBc454C7092d3aD051B54aB6663e
✅ Factory 合约已部署: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
✅ QuoterV2 合约已部署: 0x8b17423CFD1882e2493983DA0dA7FD72032C67A1

=== 合约代码验证 ===
✅ WETH 合约代码存在
✅ PQUSD 合约代码存在
✅ QuoterV2 合约代码存在
```

## 🔧 验证部署

```bash
# 验证工厂合约
cast call <FACTORY_ADDRESS> "owner()" --rpc-url http://localhost:8545

# 验证路由器合约
cast call <ROUTER_ADDRESS> "factory()" --rpc-url http://localhost:8545

# 验证 WETH 合约
cast call <WETH_ADDRESS> "name()" --rpc-url http://localhost:8545

# 验证 PQUSD 合约
cast call <PQUSD_ADDRESS> "name()" --rpc-url http://localhost:8545

# 验证 QuoterV2 合约
cast call <QUOTER_V2_ADDRESS> "factory()" --rpc-url http://localhost:8545
```

## 📁 生成的文件

- `deployment_summary.md` - 完整的部署摘要
- `token_deployment_summary.md` - WETH 和 PQUSD 部署摘要
- `*.backup` - 配置文件备份

## 🌐 网络配置

### 本地测试
```bash
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://localhost:8545
```

### Base Sepolia 测试网
```bash
PRIVATE_KEY=your_private_key_here
RPC_URL=https://sepolia.base.org
ETHERSCAN_API_KEY=your_api_key_here
```

### 其他网络
```bash
PRIVATE_KEY=your_private_key_here
RPC_URL=https://your_rpc_url
CHAIN_ID=your_chain_id
WETH_ADDRESS=your_weth_address
PQUSD_ADDRESS=your_pqusd_address
```

## ⚠️ 安全注意事项

1. **私钥安全**
   - 永远不要提交 `.env` 文件到版本控制
   - 使用安全的密钥管理工具

2. **网络选择**
   - 测试环境：使用 Anvil 或测试网
   - 生产环境：使用主网或目标网络

3. **验证部署**
   - 脚本会自动验证部署
   - 建议手动验证关键功能

## 🆘 故障排除

### 常见问题

1. **找不到 .env 文件**
   ```bash
   cp env.example .env
   ```

2. **编译失败**
   ```bash
   forge install
   forge build
   ```

3. **部署失败**
   - 检查私钥是否正确
   - 确保账户有足够的 ETH
   - 验证 RPC URL 是否可访问

### 重新部署

```bash
# 清理之前的部署
rm -f deployment_summary.md
rm -f token_deployment_summary.md

# 恢复备份文件（如果需要）
cp lib/v3-periphery/contracts/libraries/PoolAddress.sol.backup lib/v3-periphery/contracts/libraries/PoolAddress.sol
cp src/deployConstructor/SwapRouter.txt.backup src/deployConstructor/SwapRouter.txt
cp src/deployConstructor/NonfungiblePositionManager.txt.backup src/deployConstructor/NonfungiblePositionManager.txt

# 重新部署 WETH 和 PQUSD
./deploy_weth_pqusd.sh

# 重新运行完整部署脚本
./deploy_step_by_step.sh

# 重新部署 QuoterV2
./run_deploy_quoterV2.sh deploy
```

## 🧪 测试功能

部署完成后，您可以测试各种功能：

```bash
# 检查合约配置
./check_weth_pqusd.sh

# 测试用户操作
./run_user_operation.sh balance
./run_user_operation.sh swap
./run_user_operation.sh add-liquidity

# 测试流动性管理
./run_liquidity_management.sh mint
./run_liquidity_management.sh increase

# 测试 QuoterV2
./run_deploy_quoterV2.sh test
```

## 📚 更多信息

- [详细部署指南](STEP_BY_STEP_DEPLOYMENT.md)
- [脚本使用说明](SCRIPT_USAGE.md)
- [用户操作指南](USER_OPERATION_USAGE.md)
- [原始项目方法](ORIGINAL_DEPLOYMENT_GUIDE.md)

---

*这个快速开始指南帮助您在几分钟内完成 Uniswap V3 的部署！*