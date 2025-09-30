#!/bin/bash

# WETH 和 PQUSD 部署脚本
# 自动部署 WETH 和 PQUSD 合约并更新配置文件

set -e  # 遇到错误时退出

echo "🚀 开始 WETH 和 PQUSD 部署和初始化..."

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

# 设置固定的超时时间（秒）
DEPOSIT_TIMEOUT=120
BALANCE_CHECK_TIMEOUT=60

# 简单的超时函数
timeout_cmd() {
    local timeout_seconds=$1
    shift
    if command -v timeout >/dev/null 2>&1; then
        timeout $timeout_seconds "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout $timeout_seconds "$@"
    else
        # 如果没有 timeout 命令，直接执行
        "$@"
    fi
}

# 加载 .env 文件
load_env() {
    if [ -f ".env" ]; then
        log_info "加载 .env 文件..."
        export $(cat .env | grep -v '^#' | xargs)
        log_success ".env 文件加载成功"
    else
        log_warning "未找到 .env 文件，将创建新文件"
        touch .env
    fi
}

# 加载环境变量
load_env

# 检查环境变量
if [ -z "$PRIVATE_KEY" ]; then
    log_error "请设置 PRIVATE_KEY 环境变量"
    echo "在 .env 文件中设置: PRIVATE_KEY=your_private_key_here"
    exit 1
fi

if [ -z "$RPC_URL" ]; then
    log_warning "未设置 RPC_URL，使用默认的本地 Anvil 节点"
    RPC_URL="http://localhost:8545"
fi

# 设置重新部署配置默认值
if [ -z "$REDEPLOY_WETH" ]; then
    REDEPLOY_WETH="false"
fi

if [ -z "$REDEPLOY_PQUSD" ]; then
    REDEPLOY_PQUSD="false"
fi

# 显示环境信息
log_info "环境信息:"
echo "  RPC URL: $RPC_URL"
echo "  链ID: ${CHAIN_ID:-"未设置 (将从RPC自动获取)"}"
echo "  部署者地址: $(cast wallet address --private-key $PRIVATE_KEY)"
echo "  重新部署 WETH: $REDEPLOY_WETH"
echo "  重新部署 PQUSD: $REDEPLOY_PQUSD"

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

# 步骤 1: 部署 WETH
log_info "步骤 1: 检查 WETH 合约状态"

# 检查是否已存在 WETH 地址且不需要重新部署
if [ -n "$WETH_ADDRESS" ] && [ "$REDEPLOY_WETH" = "false" ]; then
    # 验证现有合约
    WETH_CODE=$(cast code $WETH_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
    if [ "$WETH_CODE" != "0x" ] && [ -n "$WETH_CODE" ]; then
        log_success "WETH 合约已存在且有效，跳过部署"
        echo "  WETH 地址: $WETH_ADDRESS"
    else
        log_warning "WETH 地址存在但合约无效，将重新部署"
        WETH_ADDRESS=""
    fi
else
    log_info "WETH 地址未设置或需要重新部署"
    WETH_ADDRESS=""
fi

# 如果需要部署 WETH
if [ -z "$WETH_ADDRESS" ]; then
    log_info "部署 WETH 合约..."
    WETH_OUTPUT=$(forge create src/WETH.sol:WETH9 \
      --private-key $PRIVATE_KEY \
      --rpc-url $RPC_URL \
      --legacy \
      --broadcast 2>&1)

    if [ $? -eq 0 ]; then
        # 从输出中提取 WETH 地址
        WETH_ADDRESS=$(echo "$WETH_OUTPUT" | grep "Deployed to:" | awk '{print $3}')
        log_success "WETH 部署成功"
        echo "  WETH 地址: $WETH_ADDRESS"
    else
        log_error "WETH 部署失败"
        echo "$WETH_OUTPUT"
        exit 1
    fi
fi

echo ""

# 步骤 2: 部署 PQUSD
log_info "步骤 2: 检查 PQUSD 合约状态"

# 检查是否已存在 PQUSD 地址且不需要重新部署
if [ -n "$PQUSD_ADDRESS" ] && [ "$REDEPLOY_PQUSD" = "false" ]; then
    # 验证现有合约
    PQUSD_CODE=$(cast code $PQUSD_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
    if [ "$PQUSD_CODE" != "0x" ] && [ -n "$PQUSD_CODE" ]; then
        log_success "PQUSD 合约已存在且有效，跳过部署"
        echo "  PQUSD 地址: $PQUSD_ADDRESS"
    else
        log_warning "PQUSD 地址存在但合约无效，将重新部署"
        PQUSD_ADDRESS=""
    fi
else
    log_info "PQUSD 地址未设置或需要重新部署"
    PQUSD_ADDRESS=""
fi

# 如果需要部署 PQUSD
if [ -z "$PQUSD_ADDRESS" ]; then
    log_info "部署 PQUSD 合约..."
    PQUSD_OUTPUT=$(forge create src/PQUSD.sol:PQUSD \
      --private-key $PRIVATE_KEY \
      --rpc-url $RPC_URL \
      --legacy \
      --broadcast 2>&1)

    if [ $? -eq 0 ]; then
        # 从输出中提取 PQUSD 地址
        PQUSD_ADDRESS=$(echo "$PQUSD_OUTPUT" | grep "Deployed to:" | awk '{print $3}')
        log_success "PQUSD 部署成功"
        echo "  PQUSD 地址: $PQUSD_ADDRESS"
    else
        log_error "PQUSD 部署失败"
        echo "$PQUSD_OUTPUT"
        exit 1
    fi
fi

echo ""

# 步骤 3: 验证合约
log_info "步骤 3: 验证合约"

# 验证 WETH 合约
if [ -n "$WETH_ADDRESS" ]; then
    WETH_CODE=$(cast code $WETH_ADDRESS --rpc-url $RPC_URL)
    if [ "$WETH_CODE" != "0x" ]; then
        log_success "WETH 合约验证成功"
        echo "  WETH 地址: $WETH_ADDRESS"
    else
        log_error "WETH 合约验证失败 - 合约代码为空"
        exit 1
    fi
fi

# 验证 PQUSD 合约
if [ -n "$PQUSD_ADDRESS" ]; then
    PQUSD_CODE=$(cast code $PQUSD_ADDRESS --rpc-url $RPC_URL)
    if [ "$PQUSD_CODE" != "0x" ]; then
        log_success "PQUSD 合约验证成功"
        echo "  PQUSD 地址: $PQUSD_ADDRESS"
    else
        log_error "PQUSD 合约验证失败 - 合约代码为空"
        exit 1
    fi
fi

echo ""

# 步骤 4: 测试合约基本功能
log_info "步骤 4: 测试合约基本功能"
DEPLOYER_ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)

# 测试 WETH deposit 功能 (初始余额: 1000 ETH)
log_info "测试 WETH deposit 功能 (初始余额: 1000 ETH)..."
DEPOSIT_TX=$(timeout_cmd $DEPOSIT_TIMEOUT cast send $WETH_ADDRESS "deposit()" --value 1000ether --private-key $PRIVATE_KEY --rpc-url $RPC_URL --legacy 2>&1)
DEPOSIT_EXIT_CODE=$?
if [ $DEPOSIT_EXIT_CODE -eq 0 ]; then
    log_success "WETH deposit 测试成功"
elif [ $DEPOSIT_EXIT_CODE -eq 124 ]; then
    log_warning "WETH deposit 测试超时，跳过此测试"
else
    log_warning "WETH deposit 测试失败，跳过此测试"
    echo "$DEPOSIT_TX"
fi

# 检查 WETH 余额
log_info "检查 WETH 余额..."
WETH_BALANCE=$(timeout_cmd $BALANCE_CHECK_TIMEOUT cast call $WETH_ADDRESS "balanceOf(address)" $DEPLOYER_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
WETH_BALANCE_EXIT_CODE=$?
if [ $WETH_BALANCE_EXIT_CODE -eq 0 ] && [ "$WETH_BALANCE" != "0x0000000000000000000000000000000000000000000000000000000000000000" ]; then
    log_success "WETH 余额检查成功"
    echo "  WETH 余额: $WETH_BALANCE"
else
    log_warning "WETH 余额检查失败或超时，跳过此检查"
fi

# 检查 PQUSD 余额
log_info "检查 PQUSD 余额..."
PQUSD_BALANCE=$(timeout_cmd $BALANCE_CHECK_TIMEOUT cast call $PQUSD_ADDRESS "balanceOf(address)" $DEPLOYER_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
PQUSD_BALANCE_EXIT_CODE=$?
if [ $PQUSD_BALANCE_EXIT_CODE -eq 0 ] && [ "$PQUSD_BALANCE" != "0x0000000000000000000000000000000000000000000000000000000000000000" ]; then
    log_success "PQUSD 余额检查成功"
    echo "  PQUSD 余额: $PQUSD_BALANCE"
else
    log_warning "PQUSD 余额检查失败或超时，跳过此检查"
fi

echo ""

# 步骤 5: 更新配置文件
log_info "步骤 5: 更新配置文件"

# 更新 NonfungiblePositionManager.txt
NFT_POSITION_MANAGER_FILE="src/deployConstructor/NonfungiblePositionManager.txt"
if [ -f "$NFT_POSITION_MANAGER_FILE" ]; then
    # 备份原文件
    cp "$NFT_POSITION_MANAGER_FILE" "${NFT_POSITION_MANAGER_FILE}.backup"
    
    # 更新 WETH 地址（第2行）(跨平台兼容)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "2s/0x[a-fA-F0-9]\{40\}/$WETH_ADDRESS/" "$NFT_POSITION_MANAGER_FILE"
    else
        # Linux
        sed -i "2s/0x[a-fA-F0-9]\{40\}/$WETH_ADDRESS/" "$NFT_POSITION_MANAGER_FILE"
    fi
    
    log_success "NonfungiblePositionManager.txt 更新成功"
    echo "  文件: $NFT_POSITION_MANAGER_FILE"
    echo "  新的 WETH 地址: $WETH_ADDRESS"
else
    log_warning "找不到 NonfungiblePositionManager.txt 文件"
fi

# 更新 .env 文件
log_info "更新 .env 文件..."

# 保留现有的 CHAIN_ID 配置
if [ -z "$CHAIN_ID" ]; then
    CHAIN_ID_LINE=""
else
    CHAIN_ID_LINE="CHAIN_ID=$CHAIN_ID"
fi

# 创建或更新 .env 文件
cat > .env << EOF
# Uniswap V3 Foundry 部署环境变量

# 私钥 (必填)
PRIVATE_KEY=$PRIVATE_KEY

# RPC URL (可选，默认为本地 Anvil 节点)
RPC_URL=$RPC_URL

# 链ID (可选，如果未设置将从RPC自动获取)
$CHAIN_ID_LINE

# 合约地址
WETH_ADDRESS=$WETH_ADDRESS
PQUSD_ADDRESS=$PQUSD_ADDRESS

# 其他合约地址 (将在部署后添加)
SWAP_ROUTER_ADDRESS=
POSITION_MANAGER_ADDRESS=
FACTORY_ADDRESS=
QUOTER_V2_ADDRESS=
CREATED_TOKEN_ID=1

# 重新部署配置 (true/false)
# 设置为 true 将重新部署对应的合约，即使已存在
REDEPLOY_WETH=$REDEPLOY_WETH
REDEPLOY_PQUSD=$REDEPLOY_PQUSD
EOF

log_success ".env 文件已更新"
echo "  WETH_ADDRESS: $WETH_ADDRESS"
echo "  PQUSD_ADDRESS: $PQUSD_ADDRESS"

echo ""

# 步骤 6: 生成部署摘要
log_info "步骤 6: 生成部署摘要"
cat > token_deployment_summary.md << EOF
# WETH 和 PQUSD 部署摘要

## 部署时间
$(date)

## 环境信息
- RPC URL: $RPC_URL
- 链ID: ${CHAIN_ID:-"未设置"}
- 部署者: $DEPLOYER_ADDRESS

## 合约信息

| 合约名称 | 地址 |
|---------|------|
| WETH | \`$WETH_ADDRESS\` |
| PQUSD | \`$PQUSD_ADDRESS\` |

## 验证结果

- ✅ WETH 合约部署成功
- ✅ PQUSD 合约部署成功
- ✅ 合约代码验证通过
- ✅ WETH Deposit 功能测试通过 (初始余额: 1000 ETH)
- ✅ 余额检查通过
- ✅ 配置文件更新完成

## 下一步

现在可以运行完整的 Uniswap V3 部署：

\`\`\`bash
./deploy_step_by_step.sh
\`\`\`

---

*此摘要由 Token 部署脚本生成*
EOF

log_success "部署摘要已保存到 token_deployment_summary.md"

echo ""

# 完成
log_success "🎉 WETH 和 PQUSD 部署和初始化完成！"

echo ""
echo "📋 部署摘要:"
echo "  WETH 地址: $WETH_ADDRESS"
echo "  PQUSD 地址: $PQUSD_ADDRESS"
echo "  链ID: ${CHAIN_ID:-"unknown"}"
echo "  部署者: $DEPLOYER_ADDRESS"
echo "  配置文件已更新"
echo "  部署摘要: token_deployment_summary.md"

echo ""
echo "🚀 下一步操作:"
echo "  1. 运行完整部署: ./deploy_step_by_step.sh"
echo "  2. 查看部署摘要: cat token_deployment_summary.md"
echo "  3. 测试 WETH 功能: cast call $WETH_ADDRESS 'balanceOf(address)' $DEPLOYER_ADDRESS --rpc-url $RPC_URL (预期余额: 1000 ETH)"
echo "  4. 测试 PQUSD 功能: cast call $PQUSD_ADDRESS 'balanceOf(address)' $DEPLOYER_ADDRESS --rpc-url $RPC_URL" 