# Uniswap V3 Foundry 部署项目

这是一个使用 Foundry 部署 Uniswap V3 的完整项目。项目包含了所有必要的合约部署脚本和工具，支持 WETH 和 PQUSD 代币。

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

### 3. 配置环境变量
```bash
# 复制示例文件
cp env.example .env

# 编辑 .env 文件
nano .env
```

### 4. 部署 WETH 和 PQUSD
```bash
# 部署代币合约
./deploy_weth_pqusd.sh
```

### 5. 检查合约配置
```bash
# 检查 WETH 和 PQUSD 合约
./check_weth_pqusd.sh
```

### 6. 部署 Uniswap V3
```bash
# 启动 Anvil 节点
anvil

# 在另一个终端中运行部署
./deploy_step_by_step.sh
```

### 7. 部署 QuoterV2
```bash
# 部署 QuoterV2 合约
./run_deploy_quoterV2.sh deploy

# 验证部署
./run_deploy_quoterV2.sh verify

# 测试功能
./run_deploy_quoterV2.sh test
```

## 📁 项目结构

```
uniswapV3_foundry_deployment/
├── script/
│   ├── deployQuoterV2.s.sol      # QuoterV2 部署脚本
│   ├── liquidityManagement.s.sol  # 流动性管理脚本
│   ├── useOperation.s.sol         # 用户操作脚本
│   └── wethDeposit.s.sol         # WETH 存款脚本
├── src/
│   ├── WETH.sol                  # WETH 合约
│   ├── PQUSD.sol                 # PQUSD 代币合约
│   └── deployConstructor/        # 部署构造函数
├── lib/                          # 依赖库
├── deploy_weth_pqusd.sh         # WETH 和 PQUSD 部署脚本
├── check_weth_pqusd.sh          # 合约配置检查脚本
├── deploy_step_by_step.sh       # 完整部署脚本
├── run_deploy_quoterV2.sh       # QuoterV2 部署脚本
├── run_liquidity_management.sh   # 流动性管理脚本
├── run_user_operation.sh         # 用户操作脚本
├── QUICK_START.md               # 快速开始指南
└── foundry.toml                 # Foundry 配置
```

## 🔧 部署的合约

### 代币合约
1. **WETH** - Wrapped Ether 合约
2. **PQUSD** - PQ USD 代币合约

### Uniswap V3 核心合约
3. **UniswapV3Factory** - 工厂合约，用于创建流动性池
4. **SwapRouter** - 交换路由器，用于执行代币交换
5. **NonfungibleTokenPositionDescriptor** - NFT 位置描述符
6. **NonfungiblePositionManager** - NFT 位置管理器
7. **QuoterV2** - 价格报价合约

## 🌐 支持的网络

### 本地测试 (Anvil)
- **RPC URL**: `http://localhost:8545`
- **Chain ID**: 31337
- **WETH**: 自动部署
- **PQUSD**: 自动部署

### Base Sepolia 测试网
- **WETH 地址**: `0x4200000000000000000000000000000000000006`
- **RPC URL**: `https://sepolia.base.org`
- **Chain ID**: 84532

### 其他网络
可以通过修改 `.env` 文件中的地址来支持其他网络。

## 📋 部署脚本

### 代币部署 (`deploy_weth_pqusd.sh`)
- 部署 WETH 和 PQUSD 合约
- 自动更新配置文件
- 生成部署摘要

### 合约检查 (`check_weth_pqusd.sh`)
- 验证 WETH 和 PQUSD 合约
- 测试合约基本功能
- 检查部署者余额

### 完整部署 (`deploy_step_by_step.sh`)
- 使用 Anvil 本地节点
- 自动检查合约配置
- 逐步部署所有 Uniswap V3 合约

### QuoterV2 部署 (`run_deploy_quoterV2.sh`)
- 部署 QuoterV2 合约
- 验证部署状态
- 测试报价功能

### 用户操作 (`run_user_operation.sh`)
- 代币交换 (WETH ↔ PQUSD)
- 添加流动性
- 查询余额和池信息

### 流动性管理 (`run_liquidity_management.sh`)
- 添加流动性
- 增加/减少流动性
- 收集费用
- 销毁位置

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

## 📡 事件监听

项目提供了完整的事件监听和解码功能：

### 基础事件监听
```bash
# 监听 Pool 事件
./run_event_monitor.sh pool-events [pool_address]

# 监听 Factory 事件
./run_event_monitor.sh factory-events [factory_address]

# 监听 Position Manager 事件
./run_event_monitor.sh position-events [position_manager_address]

# 监听所有事件
./run_event_monitor.sh all-events
```

### 实时事件监听
```bash
# 实时监听 Pool 事件
./run_realtime_monitor.sh pool-follow [pool_address]

# 实时监听所有事件
./run_realtime_monitor.sh all-follow

# 解码日志文件
./run_realtime_monitor.sh decode-logs events.log
```

### 支持的事件类型
- **Pool 事件**: Initialize, Mint, Burn, Swap, Collect, Flash
- **Factory 事件**: PoolCreated, OwnerChanged
- **Position Manager 事件**: IncreaseLiquidity, DecreaseLiquidity, Collect

详细使用说明请参考 [EVENT_MONITOR_USAGE.md](./EVENT_MONITOR_USAGE.md)

## 🔍 验证部署

部署完成后，您可以使用以下命令验证合约：

```bash
# 检查代币合约
cast call <WETH_ADDRESS> "name()" --rpc-url $RPC_URL
cast call <PQUSD_ADDRESS> "name()" --rpc-url $RPC_URL

# 检查工厂合约
cast call <FACTORY_ADDRESS> "owner()" --rpc-url $RPC_URL

# 检查路由器合约
cast call <ROUTER_ADDRESS> "factory()" --rpc-url $RPC_URL

# 检查 QuoterV2 合约
cast call <QUOTER_V2_ADDRESS> "factory()" --rpc-url $RPC_URL
```

### 验证示例

```bash
# 使用项目中的 RPC URL
export RPC_URL=http://13.54.171.239:8123

# 验证 WETH 合约
cast call 0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5 "name()" --rpc-url $RPC_URL
# 输出: Wrapped Ether

# 验证 PQUSD 合约
cast call 0x1984973E205CFBc454C7092d3aD051B54aB6663e "name()" --rpc-url $RPC_URL
# 输出: PQ USD

# 验证 Factory 合约
cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "owner()" --rpc-url $RPC_URL
```

## 🛠️ 环境要求

- Foundry 最新版本
- Node.js (可选，用于额外工具)
- 足够的 ETH 余额支付 gas 费用

## 📚 文档

- [QUICK_START.md](./QUICK_START.md) - 快速开始指南
- [USER_OPERATION_USAGE.md](./USER_OPERATION_USAGE.md) - 用户操作指南
- [SCRIPT_USAGE.md](./SCRIPT_USAGE.md) - 脚本使用说明
- [STEP_BY_STEP_DEPLOYMENT.md](./STEP_BY_STEP_DEPLOYMENT.md) - 详细部署指南
- [EVENT_MONITOR_USAGE.md](./EVENT_MONITOR_USAGE.md) - 事件监听和解码指南
- [Foundry 文档](https://book.getfoundry.sh/)
- [Uniswap V3 文档](https://docs.uniswap.org/)

## 参考

https://github.com/MarcusWentz/uniswapV3_foundry_deployment/blob/main/README.md

