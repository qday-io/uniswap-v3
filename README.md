# Uniswap V3 Foundry 部署项目

这是一个使用 Foundry 部署 Uniswap V3 的完整项目。项目包含了所有必要的合约部署脚本和工具。

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone <your-repo-url>
cd uniswapV3_foundry_deployment
```

### 2. 安装依赖
```bash
forge install
forge build
```

### 3. 检查 WETH 配置 (推荐)
```bash
# 检查 WETH 合约是否已部署
./check_weth.sh
```

### 4. 本地测试部署
```bash
# 启动 Anvil 节点
anvil

# 在另一个终端中运行部署
./deploy_step_by_step.sh
```

### 4. 生产部署
```bash
# 设置环境变量
export PRIVATE_KEY=your_private_key_here
export RPC_URL=https://sepolia.base.org
export ETHERSCAN_API_KEY=your_etherscan_api_key_here

# 运行生产部署
./deploy-production.sh
```

## 📁 项目结构

```
uniswapV3_foundry_deployment/
├── script/
│   └── deployUniswapV3.s.sol    # 主要部署脚本
├── src/                          # 自定义合约
├── lib/                          # 依赖库
├── deploy.sh                     # 本地部署脚本
├── deploy-production.sh          # 生产部署脚本
├── DEPLOYMENT_GUIDE.md          # 详细部署指南
└── foundry.toml                 # Foundry 配置
```

## 🔧 部署的合约

1. **UniswapV3Factory** - 工厂合约，用于创建流动性池
2. **SwapRouter** - 交换路由器，用于执行代币交换
3. **NonfungibleTokenPositionDescriptor** - NFT 位置描述符
4. **NonfungiblePositionManager** - NFT 位置管理器

## 🌐 支持的网络

### Base Sepolia 测试网
- **WETH 地址**: `0x4200000000000000000000000000000000000006`
- **RPC URL**: `https://sepolia.base.org`
- **Chain ID**: 84532

### 其他网络
可以通过修改 `script/deployUniswapV3.s.sol` 中的 WETH 地址来支持其他网络。

## 📋 部署脚本

### WETH 检查 (`check_weth.sh`)
- 验证 WETH 合约是否存在
- 测试 WETH 基本功能
- 检查部署者 WETH 余额

### 本地测试 (`deploy_step_by_step.sh`)
- 使用 Anvil 本地节点
- 自动检查 WETH 配置
- 逐步部署所有合约

### WETH 部署 (`deploy_weth.sh`)
- 部署 WETH 合约到本地网络
- 自动更新配置文件
- 生成部署摘要

## 🔍 验证部署

部署完成后，您可以使用以下命令验证合约：

```bash
# 检查工厂合约
cast call <FACTORY_ADDRESS> "owner()" --rpc-url $RPC_URL

# 检查路由器合约
cast call <ROUTER_ADDRESS> "factory()" --rpc-url $RPC_URL
```

## 🛠️ 环境要求

- Foundry 最新版本
- Node.js (可选，用于额外工具)
- 足够的 ETH 余额支付 gas 费用

## 📚 文档

- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - 详细部署指南
- [Foundry 文档](https://book.getfoundry.sh/)
- [Uniswap V3 文档](https://docs.uniswap.org/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## ⚠️ 免责声明

这是一个教育项目，请在生产环境中使用前进行充分测试。作者不对任何损失负责。 

