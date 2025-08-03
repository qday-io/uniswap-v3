#!/bin/bash

# Uniswap V3 Foundry 逐步部署脚本
# 基于 MarcusWentz 的原始项目方法

set -e  # 遇到错误时退出

echo "🚀 开始 Uniswap V3 Foundry 逐步部署..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 加载 .env 文件
load_env() {
    if [ -f ".env" ]; then
        log_info "加载 .env 文件..."
        export $(cat .env | grep -v '^#' | xargs)
        log_success ".env 文件加载成功"
    else
        log_warning "未找到 .env 文件，将使用环境变量"
    fi
}

# 加载环境变量
load_env

# 检查环境变量
if [ -z "$PRIVATE_KEY" ]; then
    log_error "请设置 PRIVATE_KEY 环境变量"
    echo "方法 1: 在 .env 文件中设置 PRIVATE_KEY=your_private_key_here"
    echo "方法 2: 在命令行中设置 export PRIVATE_KEY=your_private_key_here"
    exit 1
fi

if [ -z "$RPC_URL" ]; then
    log_warning "未设置 RPC_URL，使用默认的本地 Anvil 节点"
    RPC_URL="http://localhost:8545"
fi

# 显示环境信息
log_info "环境信息:"
echo "  RPC URL: $RPC_URL"
echo "  部署者地址: $(cast wallet address --private-key $PRIVATE_KEY)"

# 检查 WETH 配置
log_info "检查 WETH 配置..."
if [ -z "$WETH_ADDRESS" ]; then
    log_warning "未设置 WETH_ADDRESS，将使用默认地址"
    WETH_ADDRESS="0x4200000000000000000000000000000000000006"
else
    log_info "WETH 地址: $WETH_ADDRESS"
fi

# 验证 WETH 合约是否存在
log_info "验证 WETH 合约是否存在..."
WETH_CODE=$(cast code $WETH_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
if [ "$WETH_CODE" = "0x" ] || [ -z "$WETH_CODE" ]; then
    log_error "WETH 合约验证失败 - 地址 $WETH_ADDRESS 没有合约代码"
    echo "请先运行 WETH 部署脚本:"
    echo "  ./deploy_weth.sh"
    exit 1
else
    log_success "WETH 合约验证成功"
    echo "  WETH 地址: $WETH_ADDRESS"
fi

# 编译项目
log_info "编译项目..."
forge build
if [ $? -eq 0 ]; then
    log_success "编译成功"
else
    log_error "编译失败"
    exit 1
fi

echo ""

# 步骤 1: 部署 UniswapV3FactoryFoundry
log_info "步骤 1: 部署 UniswapV3FactoryFoundry"
FACTORY_OUTPUT=$(forge create src/UniswapV3FactoryFoundry.sol:UniswapV3FactoryFoundry \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --legacy --broadcast 2>&1)

if [ $? -eq 0 ]; then
    FACTORY_ADDRESS=$(echo "$FACTORY_OUTPUT" | grep "Deployed to:" | awk '{print $3}')
    FACTORY_TX_HASH=$(echo "$FACTORY_OUTPUT" | grep "Transaction hash:" | awk '{print $3}')
    log_success "UniswapV3FactoryFoundry 部署成功"
    echo "  地址: $FACTORY_ADDRESS"
    echo "  交易哈希: $FACTORY_TX_HASH"
else
    log_error "UniswapV3FactoryFoundry 部署失败"
    echo "$FACTORY_OUTPUT"
    exit 1
fi

echo ""

# 步骤 2: 获取 POOL_INIT_CODE_HASH
log_info "步骤 2: 获取 POOL_INIT_CODE_HASH"
POOL_INIT_CODE_HASH=$(cast call $FACTORY_ADDRESS "POOL_INIT_CODE_HASH()" --rpc-url $RPC_URL)
if [ $? -eq 0 ]; then
    log_success "获取 POOL_INIT_CODE_HASH 成功"
    echo "  POOL_INIT_CODE_HASH: $POOL_INIT_CODE_HASH"
else
    log_error "获取 POOL_INIT_CODE_HASH 失败"
    exit 1
fi

echo ""

# 步骤 3: 更新 PoolAddress.sol
log_info "步骤 3: 更新 PoolAddress.sol"
POOL_ADDRESS_FILE="lib/v3-periphery/contracts/libraries/PoolAddress.sol"
if [ -f "$POOL_ADDRESS_FILE" ]; then
    # 备份原文件
    cp "$POOL_ADDRESS_FILE" "${POOL_ADDRESS_FILE}.backup"
    
    # 更新 POOL_INIT_CODE_HASH
    sed -i '' "s/0x[a-fA-F0-9]\{64\}/$POOL_INIT_CODE_HASH/g" "$POOL_ADDRESS_FILE"
    
    log_success "PoolAddress.sol 更新成功"
    echo "  文件: $POOL_ADDRESS_FILE"
    echo "  新的 POOL_INIT_CODE_HASH: $POOL_INIT_CODE_HASH"
else
    log_error "找不到 PoolAddress.sol 文件"
    exit 1
fi

echo ""

# 步骤 4: 更新 SwapRouter 构造函数参数
log_info "步骤 4: 更新 SwapRouter 构造函数参数"
SWAP_ROUTER_ARGS_FILE="src/deployConstructor/SwapRouter.txt"
if [ -f "$SWAP_ROUTER_ARGS_FILE" ]; then
    # 备份原文件
    cp "$SWAP_ROUTER_ARGS_FILE" "${SWAP_ROUTER_ARGS_FILE}.backup"
    
    # 更新工厂地址
    sed -i '' "1s/0x[a-fA-F0-9]\{40\}/$FACTORY_ADDRESS/" "$SWAP_ROUTER_ARGS_FILE"
    
    log_success "SwapRouter 构造函数参数更新成功"
    echo "  文件: $SWAP_ROUTER_ARGS_FILE"
    echo "  新的工厂地址: $FACTORY_ADDRESS"
else
    log_error "找不到 SwapRouter.txt 文件"
    exit 1
fi

echo ""

# 步骤 5: 部署 SwapRouterFoundry
log_info "步骤 5: 部署 SwapRouterFoundry"
SWAP_ROUTER_OUTPUT=$(forge create src/SwapRouterFoundry.sol:SwapRouterFoundry \
  --constructor-args-path src/deployConstructor/SwapRouter.txt \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --legacy --broadcast 2>&1)

if [ $? -eq 0 ]; then
    SWAP_ROUTER_ADDRESS=$(echo "$SWAP_ROUTER_OUTPUT" | grep "Deployed to:" | awk '{print $3}')
    SWAP_ROUTER_TX_HASH=$(echo "$SWAP_ROUTER_OUTPUT" | grep "Transaction hash:" | awk '{print $3}')
    log_success "SwapRouterFoundry 部署成功"
    echo "  地址: $SWAP_ROUTER_ADDRESS"
    echo "  交易哈希: $SWAP_ROUTER_TX_HASH"
else
    log_error "SwapRouterFoundry 部署失败"
    echo "$SWAP_ROUTER_OUTPUT"
    exit 1
fi

echo ""

# 步骤 6: 部署 NFTDescriptor
log_info "步骤 6: 部署 NFTDescriptor"
NFT_DESCRIPTOR_OUTPUT=$(forge create lib/v3-periphery/contracts/libraries/NFTDescriptor.sol:NFTDescriptor \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --legacy --broadcast 2>&1)

if [ $? -eq 0 ]; then
    NFT_DESCRIPTOR_ADDRESS=$(echo "$NFT_DESCRIPTOR_OUTPUT" | grep "Deployed to:" | awk '{print $3}')
    NFT_DESCRIPTOR_TX_HASH=$(echo "$NFT_DESCRIPTOR_OUTPUT" | grep "Transaction hash:" | awk '{print $3}')
    log_success "NFTDescriptor 部署成功"
    echo "  地址: $NFT_DESCRIPTOR_ADDRESS"
    echo "  交易哈希: $NFT_DESCRIPTOR_TX_HASH"
else
    log_error "NFTDescriptor 部署失败"
    echo "$NFT_DESCRIPTOR_OUTPUT"
    exit 1
fi

echo ""

# 步骤 7: 部署 NonfungibleTokenPositionDescriptorFoundry
log_info "步骤 7: 部署 NonfungibleTokenPositionDescriptorFoundry"
NFT_POSITION_DESCRIPTOR_OUTPUT=$(forge create src/NonfungibleTokenPositionDescriptorFoundry.sol:NonfungibleTokenPositionDescriptorFoundry \
  --constructor-args-path src/deployConstructor/NonfungibleTokenPositionDescriptor.txt \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --legacy --broadcast \
  --libraries lib/v3-periphery/contracts/libraries/NFTDescriptor.sol:NFTDescriptor:$NFT_DESCRIPTOR_ADDRESS 2>&1)

if [ $? -eq 0 ]; then
    NFT_POSITION_DESCRIPTOR_ADDRESS=$(echo "$NFT_POSITION_DESCRIPTOR_OUTPUT" | grep "Deployed to:" | awk '{print $3}')
    NFT_POSITION_DESCRIPTOR_TX_HASH=$(echo "$NFT_POSITION_DESCRIPTOR_OUTPUT" | grep "Transaction hash:" | awk '{print $3}')
    log_success "NonfungibleTokenPositionDescriptorFoundry 部署成功"
    echo "  地址: $NFT_POSITION_DESCRIPTOR_ADDRESS"
    echo "  交易哈希: $NFT_POSITION_DESCRIPTOR_TX_HASH"
else
    log_error "NonfungibleTokenPositionDescriptorFoundry 部署失败"
    echo "$NFT_POSITION_DESCRIPTOR_OUTPUT"
    exit 1
fi

echo ""

# 步骤 8: 更新 NonfungiblePositionManager 构造函数参数
log_info "步骤 8: 更新 NonfungiblePositionManager 构造函数参数"
NFT_POSITION_MANAGER_ARGS_FILE="src/deployConstructor/NonfungiblePositionManager.txt"
if [ -f "$NFT_POSITION_MANAGER_ARGS_FILE" ]; then
    # 备份原文件
    cp "$NFT_POSITION_MANAGER_ARGS_FILE" "${NFT_POSITION_MANAGER_ARGS_FILE}.backup"
    
    # 更新工厂地址和描述符地址
    sed -i '' "1s/0x[a-fA-F0-9]\{40\}/$FACTORY_ADDRESS/" "$NFT_POSITION_MANAGER_ARGS_FILE"
    sed -i '' "3s/0x[a-fA-F0-9]\{40\}/$NFT_POSITION_DESCRIPTOR_ADDRESS/" "$NFT_POSITION_MANAGER_ARGS_FILE"
    
    log_success "NonfungiblePositionManager 构造函数参数更新成功"
    echo "  文件: $NFT_POSITION_MANAGER_ARGS_FILE"
    echo "  新的工厂地址: $FACTORY_ADDRESS"
    echo "  新的描述符地址: $NFT_POSITION_DESCRIPTOR_ADDRESS"
else
    log_error "找不到 NonfungiblePositionManager.txt 文件"
    exit 1
fi

echo ""

# 步骤 9: 部署 NonfungiblePositionManagerFoundry
log_info "步骤 9: 部署 NonfungiblePositionManagerFoundry"
NFT_POSITION_MANAGER_OUTPUT=$(forge create src/NonfungiblePositionManagerFoundry.sol:NonfungiblePositionManagerFoundry \
  --constructor-args-path src/deployConstructor/NonfungiblePositionManager.txt \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --legacy --broadcast 2>&1)

if [ $? -eq 0 ]; then
    NFT_POSITION_MANAGER_ADDRESS=$(echo "$NFT_POSITION_MANAGER_OUTPUT" | grep "Deployed to:" | awk '{print $3}')
    NFT_POSITION_MANAGER_TX_HASH=$(echo "$NFT_POSITION_MANAGER_OUTPUT" | grep "Transaction hash:" | awk '{print $3}')
    log_success "NonfungiblePositionManagerFoundry 部署成功"
    echo "  地址: $NFT_POSITION_MANAGER_ADDRESS"
    echo "  交易哈希: $NFT_POSITION_MANAGER_TX_HASH"
else
    log_error "NonfungiblePositionManagerFoundry 部署失败"
    echo "$NFT_POSITION_MANAGER_OUTPUT"
    exit 1
fi

echo ""

# 更新 .env 文件
log_info "更新 .env 文件..."
if [ -f ".env" ]; then
    # 备份原文件
    cp ".env" ".env.backup"
    
    # 更新或添加合约地址
    if grep -q "FACTORY_ADDRESS" .env; then
        sed -i '' "s/FACTORY_ADDRESS=.*/FACTORY_ADDRESS=$FACTORY_ADDRESS/" .env
    else
        echo "FACTORY_ADDRESS=$FACTORY_ADDRESS" >> .env
    fi
    
    if grep -q "SWAP_ROUTER_ADDRESS" .env; then
        sed -i '' "s/SWAP_ROUTER_ADDRESS=.*/SWAP_ROUTER_ADDRESS=$SWAP_ROUTER_ADDRESS/" .env
    else
        echo "SWAP_ROUTER_ADDRESS=$SWAP_ROUTER_ADDRESS" >> .env
    fi
    
    if grep -q "POSITION_MANAGER_ADDRESS" .env; then
        sed -i '' "s/POSITION_MANAGER_ADDRESS=.*/POSITION_MANAGER_ADDRESS=$NFT_POSITION_MANAGER_ADDRESS/" .env
    else
        echo "POSITION_MANAGER_ADDRESS=$NFT_POSITION_MANAGER_ADDRESS" >> .env
    fi
    
    log_success ".env 文件更新成功"
    echo "  FACTORY_ADDRESS: $FACTORY_ADDRESS"
    echo "  SWAP_ROUTER_ADDRESS: $SWAP_ROUTER_ADDRESS"
    echo "  POSITION_MANAGER_ADDRESS: $NFT_POSITION_MANAGER_ADDRESS"
else
    log_warning "未找到 .env 文件，跳过更新"
fi

echo ""

# 生成部署摘要
log_info "生成部署摘要..."
cat > deployment_summary.md << EOF
# Uniswap V3 Foundry 部署摘要

## 部署时间
$(date)

## 环境信息
- RPC URL: $RPC_URL
- 部署者: $(cast wallet address --private-key $PRIVATE_KEY)

## 合约地址

| 合约名称 | 地址 |
|---------|------|
| UniswapV3FactoryFoundry | \`$FACTORY_ADDRESS\` |
| SwapRouterFoundry | \`$SWAP_ROUTER_ADDRESS\` |
| NFTDescriptor | \`$NFT_DESCRIPTOR_ADDRESS\` |
| NonfungibleTokenPositionDescriptorFoundry | \`$NFT_POSITION_DESCRIPTOR_ADDRESS\` |
| NonfungiblePositionManagerFoundry | \`$NFT_POSITION_MANAGER_ADDRESS\` |

## 关键配置

- **POOL_INIT_CODE_HASH**: \`$POOL_INIT_CODE_HASH\`
- **WETH 地址**: \`$WETH_ADDRESS\`

## 交易哈希

| 合约 | 交易哈希 |
|------|----------|
| UniswapV3FactoryFoundry | \`$FACTORY_TX_HASH\` |
| SwapRouterFoundry | \`$SWAP_ROUTER_TX_HASH\` |
| NFTDescriptor | \`$NFT_DESCRIPTOR_TX_HASH\` |
| NonfungibleTokenPositionDescriptorFoundry | \`$NFT_POSITION_DESCRIPTOR_TX_HASH\` |
| NonfungiblePositionManagerFoundry | \`$NFT_POSITION_MANAGER_TX_HASH\` |

---

*此摘要由自动化部署脚本生成*
EOF

log_success "部署摘要已保存到 deployment_summary.md"

echo ""
log_success "🎉 Uniswap V3 Foundry 部署完成！"
echo ""
echo "📋 部署摘要:"
echo "  Factory: $FACTORY_ADDRESS"
echo "  SwapRouter: $SWAP_ROUTER_ADDRESS"
echo "  NFTDescriptor: $NFT_DESCRIPTOR_ADDRESS"
echo "  NonfungibleTokenPositionDescriptor: $NFT_POSITION_DESCRIPTOR_ADDRESS"
echo "  NonfungiblePositionManager: $NFT_POSITION_MANAGER_ADDRESS"
echo ""
echo "📄 详细摘要已保存到: deployment_summary.md"
echo "🔧 .env 文件已更新，包含所有合约地址" 