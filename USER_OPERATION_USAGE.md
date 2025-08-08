# 用户操作脚本使用说明

本文档介绍如何使用用户操作脚本进行代币交换、流动性添加等操作。

## 脚本文件

- **`script/useOperation.s.sol`** - 用户操作脚本
- **`run_user_operation.sh`** - 用户操作运行脚本

## 环境变量要求

确保以下环境变量已设置：

```bash
export PRIVATE_KEY="your_private_key"
export WETH_ADDRESS="weth_contract_address"
export TEST_TOKEN_ADDRESS="test_token_contract_address"
export SWAP_ROUTER_ADDRESS="swap_router_contract_address"
export POSITION_MANAGER_ADDRESS="position_manager_contract_address"
export FACTORY_ADDRESS="factory_contract_address"
export RPC_URL="your_rpc_url"  # 可选，默认为 http://localhost:8545
```

## 使用方法

### 使用运行脚本

```bash
# 执行 WETH -> PQUSD 交换
./run_user_operation.sh swap

# 执行 PQUSD -> WETH 交换
./run_user_operation.sh swap-reverse

# 添加流动性
./run_user_operation.sh add-liquidity

# 查询用户余额
./run_user_operation.sh balance

# 查询池信息
./run_user_operation.sh pool-info

# 显示帮助信息
./run_user_operation.sh help
```

### 直接使用 Forge

```bash
# 执行代币交换
forge script script/useOperation.s.sol:UseOperation --sig "swapTokens()" --rpc-url <your_rpc_url> --broadcast

# 执行反向交换
forge script script/useOperation.s.sol:UseOperation --sig "swapTokensReverse()" --rpc-url <your_rpc_url> --broadcast

# 添加流动性
forge script script/useOperation.s.sol:UseOperation --sig "addUserLiquidity()" --rpc-url <your_rpc_url> --broadcast

# 查询余额
forge script script/useOperation.s.sol:UseOperation --sig "checkUserBalance()" --rpc-url <your_rpc_url>

# 查询池信息
forge script script/useOperation.s.sol:UseOperation --sig "checkPoolInfo()" --rpc-url <your_rpc_url>
```

## 功能说明

### 1. 代币交换 (swap)
- 执行 WETH -> PQUSD 交换
- 交换数量：0.01 ETH
- 自动设置授权

### 2. 反向交换 (swap-reverse)
- 执行 PQUSD -> WETH 交换
- 交换数量：50 PQUSD
- 自动设置授权

### 3. 添加流动性 (add-liquidity)
- 添加 WETH/PQUSD 流动性
- 添加数量：0.05 ETH + 50 PQUSD
- 自动设置授权

### 4. 余额查询 (balance)
- 显示用户的 WETH 和 PQUSD 余额
- 显示授权状态

### 5. 查询池信息 (checkPoolInfo)
- 显示池的基本信息
- 当前价格和 tick
- 流动性数量
- 手续费等级
- 代币地址

## 操作参数

### 交换数量
```solidity
// WETH -> PQUSD
swapRouter.exactInputSingle({
    tokenIn: wethAddress,
    tokenOut: pqusdAddress,
    // ...
});

// PQUSD -> WETH
swapRouter.exactInputSingle({
    tokenIn: pqusdAddress,
    tokenOut: wethAddress,
    // ...
});
```

### 流动性添加
```solidity
amount0Desired: 50000000000000000, // 0.05 ETH
amount1Desired: 50000000000000000000, // 50 tokens
```

### 价格范围
```solidity
tickLower: -887220, // 全范围下限
tickUpper: 887220,  // 全范围上限
```

## 示例输出

### 代币交换
```
=== 用户代币交换操作 ===
交换前余额:
WETH: 1000000000000000000
PQUSD: 1000000000000000000000
已设置 WETH 授权
交换成功: WETH -> PQUSD
交换后余额:
WETH: 990000000000000000
PQUSD: 1000000000000000000000
```

### 查询余额
```
=== 用户余额查询 ===
用户地址: 0x1234567890123456789012345678901234567890
WETH 余额: 990000000000000000
PQUSD 余额: 1000000000000000000000
授权情况:
WETH -> SwapRouter: 115792089237316195423570985008687907853269984665640564039457584007913129639935
PQUSD -> SwapRouter: 0
WETH -> PositionManager: 0
PQUSD -> PositionManager: 0
```

### 查询池信息
```
=== 池信息查询 ===
池地址: 0x1234567890123456789012345678901234567890
当前价格 (sqrtPriceX96): 1000000000000000000000000
当前 tick: 0
当前流动性: 1000000000000000000
手续费等级: 3000
Token0: 0x1234567890123456789012345678901234567890
Token1: 0x1234567890123456789012345678901234567890
```

## 注意事项

1. **余额要求**: 确保用户有足够的代币余额进行交换或添加流动性
2. **授权**: 脚本会自动处理必要的授权，但需要确保用户有足够的代币
3. **Gas 费用**: 每个操作都需要支付 gas 费用
4. **价格影响**: 大额交换可能会影响池的价格
5. **滑点保护**: 当前脚本没有设置滑点保护，生产环境建议添加

## 故障排除

1. **余额不足**: 检查用户是否有足够的代币余额
2. **授权失败**: 确保代币合约支持授权功能
3. **池不存在**: 确保池已创建并初始化
4. **网络错误**: 检查 RPC_URL 和网络连接
5. **合约地址错误**: 验证所有合约地址是否正确

## 高级用法

### 自定义交换数量
可以修改脚本中的 `amountIn` 参数来调整交换数量：

```solidity
amountIn: 100000000000000000, // 0.1 ETH (增加交换数量)
```

### 自定义流动性范围
可以修改 `tickLower` 和 `tickUpper` 来设置特定的价格范围：

```solidity
tickLower: -1000, // 自定义下限
tickUpper: 1000,  // 自定义上限
```

### 添加滑点保护
在生产环境中，建议添加滑点保护：

```solidity
amountOutMinimum: 95000000000000000000, // 5% 滑点保护
``` 