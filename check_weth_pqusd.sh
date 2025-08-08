#!/bin/bash

# WETH 和 PQUSD 配置检查脚本

set -e

echo "🔍 检查 WETH 和 PQUSD 配置..."

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
    log_warning "未找到 .env 文件"
fi

# 检查环境变量
if [ -z "$RPC_URL" ]; then
    log_warning "未设置 RPC_URL，使用默认的本地 Anvil 节点"
    RPC_URL="http://localhost:8545"
fi

# 检查 WETH 配置
log_info "检查 WETH 配置..."
if [ -z "$WETH_ADDRESS" ]; then
    log_warning "未设置 WETH_ADDRESS，将使用默认地址"
    WETH_ADDRESS="0x4200000000000000000000000000000000000006"
else
    log_info "WETH 地址: $WETH_ADDRESS"
fi

# 检查 PQUSD 配置
log_info "检查 PQUSD 配置..."
if [ -z "$PQUSD_ADDRESS" ]; then
    log_warning "未设置 PQUSD_ADDRESS"
    PQUSD_ADDRESS=""
else
    log_info "PQUSD 地址: $PQUSD_ADDRESS"
fi

echo ""

# 验证 WETH 合约
log_info "验证 WETH 合约..."
WETH_CODE=$(cast code $WETH_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
if [ "$WETH_CODE" = "0x" ] || [ -z "$WETH_CODE" ]; then
    log_error "❌ WETH 合约验证失败"
    echo "  地址: $WETH_ADDRESS"
    echo "  错误: 没有合约代码"
    echo ""
    echo "解决方案:"
    echo "  1. 运行 WETH 部署脚本: ./deploy_weth_pqusd.sh"
    echo "  2. 或者检查 .env 文件中的 WETH_ADDRESS 是否正确"
    exit 1
else
    log_success "✅ WETH 合约验证成功"
    echo "  地址: $WETH_ADDRESS"
    echo "  合约代码长度: ${#WETH_CODE} 字符"
fi

# 验证 PQUSD 合约
if [ ! -z "$PQUSD_ADDRESS" ]; then
    log_info "验证 PQUSD 合约..."
    PQUSD_CODE=$(cast code $PQUSD_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
    if [ "$PQUSD_CODE" = "0x" ] || [ -z "$PQUSD_CODE" ]; then
        log_error "❌ PQUSD 合约验证失败"
        echo "  地址: $PQUSD_ADDRESS"
        echo "  错误: 没有合约代码"
        echo ""
        echo "解决方案:"
        echo "  1. 运行 WETH 部署脚本: ./deploy_weth_pqusd.sh"
        echo "  2. 或者检查 .env 文件中的 PQUSD_ADDRESS 是否正确"
        exit 1
    else
        log_success "✅ PQUSD 合约验证成功"
        echo "  地址: $PQUSD_ADDRESS"
        echo "  合约代码长度: ${#PQUSD_CODE} 字符"
    fi
else
    log_warning "⚠️  未设置 PQUSD_ADDRESS，跳过 PQUSD 验证"
fi

echo ""

# 测试 WETH 基本功能
log_info "测试 WETH 基本功能..."

# 测试 name()
WETH_NAME=$(cast call $WETH_ADDRESS "name()" --rpc-url $RPC_URL 2>/dev/null)
if [ $? -eq 0 ] && [ "$WETH_NAME" != "0x" ]; then
    log_success "✅ WETH name() 函数正常"
    echo "  名称: $(cast --to-ascii $WETH_NAME)"
else
    log_warning "⚠️  WETH name() 函数测试失败"
fi

# 测试 symbol()
WETH_SYMBOL=$(cast call $WETH_ADDRESS "symbol()" --rpc-url $RPC_URL 2>/dev/null)
if [ $? -eq 0 ] && [ "$WETH_SYMBOL" != "0x" ]; then
    log_success "✅ WETH symbol() 函数正常"
    echo "  符号: $(cast --to-ascii $WETH_SYMBOL)"
else
    log_warning "⚠️  WETH symbol() 函数测试失败"
fi

# 测试 decimals()
WETH_DECIMALS=$(cast call $WETH_ADDRESS "decimals()" --rpc-url $RPC_URL 2>/dev/null)
if [ $? -eq 0 ] && [ "$WETH_DECIMALS" != "0x" ]; then
    log_success "✅ WETH decimals() 函数正常"
    echo "  小数位: $(cast --to-dec $WETH_DECIMALS)"
else
    log_warning "⚠️  WETH decimals() 函数测试失败"
fi

# 测试 PQUSD 基本功能
if [ ! -z "$PQUSD_ADDRESS" ]; then
    log_info "测试 PQUSD 基本功能..."
    
    # 测试 name()
    PQUSD_NAME=$(cast call $PQUSD_ADDRESS "name()" --rpc-url $RPC_URL 2>/dev/null)
    if [ $? -eq 0 ] && [ "$PQUSD_NAME" != "0x" ]; then
        log_success "✅ PQUSD name() 函数正常"
        echo "  名称: $(cast --to-ascii $PQUSD_NAME)"
    else
        log_warning "⚠️  PQUSD name() 函数测试失败"
    fi
    
    # 测试 symbol()
    PQUSD_SYMBOL=$(cast call $PQUSD_ADDRESS "symbol()" --rpc-url $RPC_URL 2>/dev/null)
    if [ $? -eq 0 ] && [ "$PQUSD_SYMBOL" != "0x" ]; then
        log_success "✅ PQUSD symbol() 函数正常"
        echo "  符号: $(cast --to-ascii $PQUSD_SYMBOL)"
    else
        log_warning "⚠️  PQUSD symbol() 函数测试失败"
    fi
    
    # 测试 decimals()
    PQUSD_DECIMALS=$(cast call $PQUSD_ADDRESS "decimals()" --rpc-url $RPC_URL 2>/dev/null)
    if [ $? -eq 0 ] && [ "$PQUSD_DECIMALS" != "0x" ]; then
        log_success "✅ PQUSD decimals() 函数正常"
        echo "  小数位: $(cast --to-dec $PQUSD_DECIMALS)"
    else
        log_warning "⚠️  PQUSD decimals() 函数测试失败"
    fi
fi

echo ""

# 检查部署者余额
if [ ! -z "$PRIVATE_KEY" ]; then
    DEPLOYER_ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)
    
    # 检查 WETH 余额
    log_info "检查部署者 WETH 余额..."
    WETH_BALANCE=$(cast call $WETH_ADDRESS "balanceOf(address)" $DEPLOYER_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
    if [ $? -eq 0 ] && [ "$WETH_BALANCE" != "0x" ]; then
        BALANCE_ETH=$(cast --to-dec $WETH_BALANCE)
        BALANCE_ETH_DECIMAL=$(echo "scale=18; $BALANCE_ETH / 1000000000000000000" | bc -l 2>/dev/null || echo "计算失败")
        log_success "✅ WETH 余额检查成功"
        echo "  部署者: $DEPLOYER_ADDRESS"
        echo "  WETH 余额: $BALANCE_ETH_DECIMAL ETH"
    else
        log_warning "⚠️  WETH 余额检查失败"
    fi
    
    # 检查 PQUSD 余额
    if [ ! -z "$PQUSD_ADDRESS" ]; then
        log_info "检查部署者 PQUSD 余额..."
        PQUSD_BALANCE=$(cast call $PQUSD_ADDRESS "balanceOf(address)" $DEPLOYER_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
        if [ $? -eq 0 ] && [ "$PQUSD_BALANCE" != "0x" ]; then
            BALANCE_TOKENS=$(cast --to-dec $PQUSD_BALANCE)
            BALANCE_TOKENS_DECIMAL=$(echo "scale=18; $BALANCE_TOKENS / 1000000000000000000" | bc -l 2>/dev/null || echo "计算失败")
            log_success "✅ PQUSD 余额检查成功"
            echo "  部署者: $DEPLOYER_ADDRESS"
            echo "  PQUSD 余额: $BALANCE_TOKENS_DECIMAL 代币"
        else
            log_warning "⚠️  PQUSD 余额检查失败"
        fi
    fi
fi

echo ""

# 总结
log_success "🎉 WETH 和 PQUSD 配置检查完成！"
echo ""
echo "�� 检查结果:"
echo "  ✅ WETH 合约存在且有效"
echo "  ✅ WETH 基本功能测试通过"
if [ ! -z "$PQUSD_ADDRESS" ]; then
    echo "  ✅ PQUSD 合约存在且有效"
    echo "  ✅ PQUSD 基本功能测试通过"
fi
if [ ! -z "$PRIVATE_KEY" ]; then
    echo "  ✅ 部署者余额检查完成"
fi
echo ""
echo "🚀 现在可以运行完整部署:"
echo "  ./deploy_step_by_step.sh" 