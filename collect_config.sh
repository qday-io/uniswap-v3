#!/bin/bash

# 收集合约ABI和环境配置的脚本
# 将合约ABI文件统一放入config/目录，并收集.env信息写入config/config-{chain_id}.md
# 
# 功能特性:
# - 自动从RPC获取链ID（如果未配置CHAIN_ID）
# - 支持多种主流网络识别
# - 自动收集合约ABI文件
# - 生成配置文件和环境摘要

set -e

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

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$PROJECT_ROOT/config"
OUT_DIR="$PROJECT_ROOT/out"

log_info "开始收集合约ABI和环境配置..."
log_info "项目根目录: $PROJECT_ROOT"
log_info "配置目录: $CONFIG_DIR"

# 创建config目录
mkdir -p "$CONFIG_DIR"

# 定义需要收集的合约ABI映射（使用数组）
CONTRACT_VARS=("WETH_ADDRESS" "PQUSD_ADDRESS" "SWAP_ROUTER_ADDRESS" "POSITION_MANAGER_ADDRESS" "FACTORY_ADDRESS" "QUOTER_V2_ADDRESS")
ABI_FILES=("WETH.sol/WETH9.json" "PQUSD.sol/PQUSD.json" "SwapRouterFoundry.sol/SwapRouterFoundry.json" "NonfungiblePositionManagerFoundry.sol/NonfungiblePositionManagerFoundry.json" "UniswapV3FactoryFoundry.sol/UniswapV3FactoryFoundry.json" "QuoterV2.sol/QuoterV2.json")

# 收集ABI文件
log_info "收集合约ABI文件..."

for i in "${!CONTRACT_VARS[@]}"; do
    contract_var="${CONTRACT_VARS[$i]}"
    abi_file="${ABI_FILES[$i]}"
    source_path="$OUT_DIR/$abi_file"
    target_name=$(echo "$contract_var" | sed 's/_ADDRESS//' | tr '[:upper:]' '[:lower:]')
    target_path="$CONFIG_DIR/${target_name}.json"
    
    log_info "处理 $contract_var -> $abi_file"
    
    if [ -f "$source_path" ]; then
        # 提取ABI部分
        if command -v jq >/dev/null 2>&1; then
            # 使用jq提取ABI
            jq '.abi' "$source_path" > "$target_path"
            log_success "✅ 已提取 $target_name ABI"
        else
            # 如果没有jq，直接复制文件
            cp "$source_path" "$target_path"
            log_warning "⚠️  未找到jq已复制完整文件 $target_name"
        fi
    else
        log_error "❌ 未找到ABI文件: $source_path"
    fi
done

# 加载.env文件
if [ -f "$PROJECT_ROOT/.env" ]; then
    log_info "加载.env文件..."
    export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)
    log_success ".env文件加载成功"
else
    log_warning "未找到.env文件使用默认值"
    # 设置默认值
    CHAIN_ID=${CHAIN_ID:-31337}
    RPC_URL=${RPC_URL:-"http://localhost:8545"}
fi

# 获取链ID
if [ -z "$CHAIN_ID" ]; then
    log_info "未设置CHAIN_ID，尝试从RPC获取..."
    if [ -n "$RPC_URL" ]; then
        # 尝试从RPC获取链ID
        log_info "正在连接RPC: $RPC_URL"
        CHAIN_ID=$(cast chain-id --rpc-url "$RPC_URL" 2>/dev/null || echo "")
        if [ -n "$CHAIN_ID" ] && [ "$CHAIN_ID" != "0" ]; then
            log_success "从RPC获取到链ID: $CHAIN_ID"
        else
            log_warning "无法从RPC获取链ID (可能RPC不可用或网络问题)，使用默认值: 31337"
            CHAIN_ID=31337
        fi
    else
        log_warning "未设置RPC_URL，使用默认链ID: 31337"
        CHAIN_ID=31337
    fi
else
    log_info "使用配置的链ID: $CHAIN_ID"
fi

# 确定网络名称
case $CHAIN_ID in
    1) NETWORK_NAME="Ethereum Mainnet" ;;
    5) NETWORK_NAME="Goerli Testnet" ;;
    11155111) NETWORK_NAME="Sepolia Testnet" ;;
    31337) NETWORK_NAME="Local Anvil" ;;
    1001) NETWORK_NAME="Custom Network" ;;
    *) NETWORK_NAME="Unknown Network" ;;
esac

# 创建配置文件
CONFIG_FILE="$CONFIG_DIR/config-${CHAIN_ID}.md"
log_info "创建配置文件: $CONFIG_FILE"

cat > "$CONFIG_FILE" << EOF
# 链配置信息 - Chain ID: $CHAIN_ID

## 网络信息
- **链ID**: $CHAIN_ID
- **RPC URL**: ${RPC_URL:-"http://localhost:8545"}
- **网络名称**: $NETWORK_NAME

## 合约地址

| 合约名称 | 环境变量 | 地址 | 状态 |
|---------|---------|------|------|
| WETH | WETH_ADDRESS | ${WETH_ADDRESS:-"未设置"} | $([ -n "$WETH_ADDRESS" ] && [ "$WETH_ADDRESS" != "0x1234567890123456789012345678901234567890" ] && echo "✅ 已部署" || echo "❌ 未部署") |
| PQUSD | PQUSD_ADDRESS | ${PQUSD_ADDRESS:-"未设置"} | $([ -n "$PQUSD_ADDRESS" ] && [ "$PQUSD_ADDRESS" != "0x1234567890123456789012345678901234567890" ] && echo "✅ 已部署" || echo "❌ 未部署") |
| Swap Router | SWAP_ROUTER_ADDRESS | ${SWAP_ROUTER_ADDRESS:-"未设置"} | $([ -n "$SWAP_ROUTER_ADDRESS" ] && [ "$SWAP_ROUTER_ADDRESS" != "0x1234567890123456789012345678901234567890" ] && echo "✅ 已部署" || echo "❌ 未部署") |
| Position Manager | POSITION_MANAGER_ADDRESS | ${POSITION_MANAGER_ADDRESS:-"未设置"} | $([ -n "$POSITION_MANAGER_ADDRESS" ] && [ "$POSITION_MANAGER_ADDRESS" != "0x1234567890123456789012345678901234567890" ] && echo "✅ 已部署" || echo "❌ 未部署") |
| Factory | FACTORY_ADDRESS | ${FACTORY_ADDRESS:-"未设置"} | $([ -n "$FACTORY_ADDRESS" ] && [ "$FACTORY_ADDRESS" != "0x1234567890123456789012345678901234567890" ] && echo "✅ 已部署" || echo "❌ 未部署") |
| Quoter V2 | QUOTER_V2_ADDRESS | ${QUOTER_V2_ADDRESS:-"未设置"} | $([ -n "$QUOTER_V2_ADDRESS" ] && [ "$QUOTER_V2_ADDRESS" != "0x1234567890123456789012345678901234567890" ] && echo "✅ 已部署" || echo "❌ 未部署") |

## 部署信息
- **部署者地址**: $(if [ -n "$PRIVATE_KEY" ]; then cast wallet address --private-key "$PRIVATE_KEY" 2>/dev/null || echo "无法获取"; else echo "未设置私钥"; fi)
- **创建代币ID**: ${CREATED_TOKEN_ID:-"未设置"}

## 部署脚本
- WETH & PQUSD: \`./deploy_weth_pqusd.sh\`
- 核心合约: \`./deploy_step_by_step.sh\`
- Quoter V2: \`./run_deploy_quoterV2.sh\`

## 验证命令
\`\`\`bash
# 检查环境变量
source .env
echo "WETH_ADDRESS: \$WETH_ADDRESS"
echo "PQUSD_ADDRESS: \$PQUSD_ADDRESS"
echo "FACTORY_ADDRESS: \$FACTORY_ADDRESS"
echo "SWAP_ROUTER_ADDRESS: \$SWAP_ROUTER_ADDRESS"
echo "POSITION_MANAGER_ADDRESS: \$POSITION_MANAGER_ADDRESS"
echo "QUOTER_V2_ADDRESS: \$QUOTER_V2_ADDRESS"

# 验证合约代码
cast code \$WETH_ADDRESS --rpc-url \$RPC_URL
cast code \$PQUSD_ADDRESS --rpc-url \$RPC_URL
\`\`\`

---
*配置文件生成时间: $(date)*
*链ID: $CHAIN_ID*
EOF

log_success "✅ 配置文件已创建: $CONFIG_FILE"

# 创建ABI索引文件
ABI_INDEX_FILE="$CONFIG_DIR/README.md"
log_info "创建ABI索引文件: $ABI_INDEX_FILE"

cat > "$ABI_INDEX_FILE" << EOF
# 合约ABI文件索引

本目录包含所有部署合约的ABI文件，用于前端集成和合约交互。

## ABI文件列表

| 合约名称 | 文件名 | 环境变量 | 描述 |
|---------|--------|---------|------|
| WETH | weth.json | WETH_ADDRESS | Wrapped Ether 代币合约 |
| PQUSD | pqusd.json | PQUSD_ADDRESS | PQUSD 代币合约 |
| Swap Router | swap_router.json | SWAP_ROUTER_ADDRESS | Uniswap V3 交换路由器 |
| Position Manager | position_manager.json | POSITION_MANAGER_ADDRESS | NFT 位置管理器 |
| Factory | factory.json | FACTORY_ADDRESS | Uniswap V3 工厂合约 |
| Quoter V2 | quoter_v2.json | QUOTER_V2_ADDRESS | 价格查询合约 V2 |

## 使用方法

### JavaScript/TypeScript
\`\`\`javascript
import wethABI from './config/weth.json';
import pqusdABI from './config/pqusd.json';
import swapRouterABI from './config/swap_router.json';

// 使用ABI创建合约实例
const wethContract = new ethers.Contract(wethAddress, wethABI, provider);
const pqusdContract = new ethers.Contract(pqusdAddress, pqusdABI, provider);
const swapRouterContract = new ethers.Contract(swapRouterAddress, swapRouterABI, provider);
\`\`\`

### Python
\`\`\`python
import json
from web3 import Web3

# 加载ABI
with open('config/weth.json', 'r') as f:
    weth_abi = json.load(f)

with open('config/pqusd.json', 'r') as f:
    pqusd_abi = json.load(f)

# 创建合约实例
weth_contract = web3.eth.contract(address=weth_address, abi=weth_abi)
pqusd_contract = web3.eth.contract(address=pqusd_address, abi=pqusd_abi)
\`\`\`

## 更新ABI文件

运行以下命令更新所有ABI文件：
\`\`\`bash
./collect_config.sh
\`\`\`

---
*最后更新: $(date)*
EOF

log_success "✅ ABI索引文件已创建: $ABI_INDEX_FILE"

# 显示收集结果
echo ""
log_info "=== 收集结果 ==="
echo "📁 配置目录: $CONFIG_DIR"
echo "📄 配置文件: $CONFIG_FILE"
echo "📋 ABI索引: $ABI_INDEX_FILE"
echo ""
echo "📦 ABI文件:"
for i in "${!CONTRACT_VARS[@]}"; do
    contract_var="${CONTRACT_VARS[$i]}"
    target_name=$(echo "$contract_var" | sed 's/_ADDRESS//' | tr '[:upper:]' '[:lower:]')
    target_path="$CONFIG_DIR/${target_name}.json"
    if [ -f "$target_path" ]; then
        echo "  ✅ $target_name.json"
    else
        echo "  ❌ $target_name.json (缺失)"
    fi
done

echo ""
log_success "🎉 配置收集完成！"
echo ""
echo "💡 提示:"
echo "  - 查看配置文件: cat $CONFIG_FILE"
echo "  - 重新收集: ./collect_config.sh"
echo "  - 检查ABI文件: ls -la $CONFIG_DIR/*.json"
echo ""
echo "🔧 链ID检测:"
echo "  - 如果未设置CHAIN_ID脚本会自动从RPC获取"
echo "  - 当前链ID: $CHAIN_ID"
echo "  - 网络名称: $NETWORK_NAME"
