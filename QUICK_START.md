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

### 5. 运行部署脚本

```bash
# 一键部署
./deploy_step_by_step.sh
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

📄 详细摘要已保存到: deployment_summary.md
```

## 🔧 验证部署

```bash
# 验证工厂合约
cast call <FACTORY_ADDRESS> "owner()" --rpc-url http://localhost:8545

# 验证路由器合约
cast call <ROUTER_ADDRESS> "factory()" --rpc-url http://localhost:8545
```

## 📁 生成的文件

- `deployment_summary.md` - 完整的部署摘要
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

# 恢复备份文件（如果需要）
cp lib/v3-periphery/contracts/libraries/PoolAddress.sol.backup lib/v3-periphery/contracts/libraries/PoolAddress.sol
cp src/deployConstructor/SwapRouter.txt.backup src/deployConstructor/SwapRouter.txt
cp src/deployConstructor/NonfungiblePositionManager.txt.backup src/deployConstructor/NonfungiblePositionManager.txt

# 重新运行脚本
./deploy_step_by_step.sh
```

## 📚 更多信息

- [详细部署指南](STEP_BY_STEP_DEPLOYMENT.md)
- [脚本使用说明](SCRIPT_USAGE.md)
- [原始项目方法](ORIGINAL_DEPLOYMENT_GUIDE.md)

---

*这个快速开始指南帮助您在几分钟内完成 Uniswap V3 的部署！* 