#!/bin/bash

# 运行完整的 Uniswap V3 流程脚本

set -e

echo "🚀 运行完整的 Uniswap V3 流程..."

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
if [ -f ".env" ]; then
    log_info "加载 .env 文件..."
    export $(cat .env | grep -v '^#' | xargs)
    log_success ".env 文件加载成功"
else
    log_error "未找到 .env 文件"
    exit 1
fi

# 检查环境变量
if [ -z "$PRIVATE_KEY" ]; then
    log_error "请设置 PRIVATE_KEY 环境变量"
    exit 1
fi

if [ -z "$RPC_URL" ]; then
    log_warning "未设置 RPC_URL，使用默认的本地 Anvil 节点"
    RPC_URL="http://localhost:8545"
fi

if [ -z "$WETH_ADDRESS" ]; then
    log_error "请设置 WETH_ADDRESS 环境变量"
    exit 1
fi

if [ -z "$TEST_TOKEN_ADDRESS" ]; then
    log_error "请设置 TEST_TOKEN_ADDRESS 环境变量"
    exit 1
fi

if [ -z "$SWAP_ROUTER_ADDRESS" ]; then
    log_error "请设置 SWAP_ROUTER_ADDRESS 环境变量"
    exit 1
fi

if [ -z "$POSITION_MANAGER_ADDRESS" ]; then
    log_error "请设置 POSITION_MANAGER_ADDRESS 环境变量"
    exit 1
fi

if [ -z "$FACTORY_ADDRESS" ]; then
    log_error "请设置 FACTORY_ADDRESS 环境变量"
    exit 1
fi

# 显示环境信息
log_info "环境信息:"
echo "  RPC URL: $RPC_URL"
echo "  WETH 地址: $WETH_ADDRESS"
echo "  TestToken 地址: $TEST_TOKEN_ADDRESS"
echo "  Factory 地址: $FACTORY_ADDRESS"
echo "  SwapRouter 地址: $SWAP_ROUTER_ADDRESS"
echo "  PositionManager 地址: $POSITION_MANAGER_ADDRESS"
DEPLOYER_ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)
echo "  部署者地址: $DEPLOYER_ADDRESS"

echo ""

# 验证合约是否存在
log_info "验证合约是否存在..."

# 验证 WETH
WETH_CODE=$(cast code $WETH_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
if [ "$WETH_CODE" = "0x" ] || [ -z "$WETH_CODE" ]; then
    log_error "WETH 合约不存在: $WETH_ADDRESS"
    exit 1
else
    log_success "WETH 合约验证成功"
fi

# 验证 TestToken
TEST_TOKEN_CODE=$(cast code $TEST_TOKEN_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
if [ "$TEST_TOKEN_CODE" = "0x" ] || [ -z "$TEST_TOKEN_CODE" ]; then
    log_error "TestToken 合约不存在: $TEST_TOKEN_ADDRESS"
    exit 1
else
    log_success "TestToken 合约验证成功"
fi

# 验证 Factory
FACTORY_CODE=$(cast code $FACTORY_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
if [ "$FACTORY_CODE" = "0x" ] || [ -z "$FACTORY_CODE" ]; then
    log_error "Factory 合约不存在: $FACTORY_ADDRESS"
    exit 1
else
    log_success "Factory 合约验证成功"
fi

# 验证 SwapRouter
SWAP_ROUTER_CODE=$(cast code $SWAP_ROUTER_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
if [ "$SWAP_ROUTER_CODE" = "0x" ] || [ -z "$SWAP_ROUTER_CODE" ]; then
    log_error "SwapRouter 合约不存在: $SWAP_ROUTER_ADDRESS"
    exit 1
else
    log_success "SwapRouter 合约验证成功"
fi

# 验证 PositionManager
POSITION_MANAGER_CODE=$(cast code $POSITION_MANAGER_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
if [ "$POSITION_MANAGER_CODE" = "0x" ] || [ -z "$POSITION_MANAGER_CODE" ]; then
    log_error "PositionManager 合约不存在: $POSITION_MANAGER_ADDRESS"
    exit 1
else
    log_success "PositionManager 合约验证成功"
fi

echo ""

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

# 运行完整的流程脚本
log_info "运行完整的 Uniswap V3 流程..."
echo ""
echo "📋 执行步骤:"
echo "  ✅ Step 1: 启用手续费等级"
echo "  ✅ Step 2: 创建池"
echo "  ✅ Step 3: 初始化池价格"
echo "  ✅ Step 4: 添加 LP 流动性"
echo "  ✅ Step 5: 执行用户 swap"
echo "  ✅ Step 6: LP 提现"
echo ""

SCRIPT_OUTPUT=$(forge script script/completeFlow.s.sol:CompleteFlowSimple \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --legacy \
  --broadcast 2>&1)

if [ $? -eq 0 ]; then
    log_success "完整流程执行成功"
    echo "$SCRIPT_OUTPUT"
else
    log_error "完整流程执行失败"
    echo "$SCRIPT_OUTPUT"
    exit 1
fi

echo ""
log_success "🎉 完整的 Uniswap V3 流程执行完成！"
echo ""
echo "📋 流程摘要:"
echo "  WETH: $WETH_ADDRESS"
echo "  TestToken: $TEST_TOKEN_ADDRESS"
echo "  Factory: $FACTORY_ADDRESS"
echo "  SwapRouter: $SWAP_ROUTER_ADDRESS"
echo "  PositionManager: $POSITION_MANAGER_ADDRESS"
echo ""
echo "✅ 所有6个步骤都已成功执行！" 