#!/bin/bash
set -e

# 加载环境变量
load_env() {
    if [ -f ".env" ]; then
        echo "Loading environment variables from .env file..."
        export $(cat .env | grep -v '^#' | xargs)
    else
        echo "Warning: .env file not found"
    fi
}

# 检查必需的环境变量
check_env_vars() {
    local required_vars=("PRIVATE_KEY" "RPC_URL" "FACTORY_ADDRESS" "POSITION_MANAGER_ADDRESS" "SWAP_ROUTER_ADDRESS")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "错误: 环境变量 $var 未设置"
            echo "请确保已设置所有必需的环境变量在 .env 文件或环境中"
            exit 1
        fi
    done
}

# 显示帮助信息
show_help() {
    echo "Uniswap V3 实时事件监听脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [选项] [合约地址]"
    echo ""
    echo "选项:"
    echo "  pool-follow [pool_address]     - 实时监听 Pool 事件"
    echo "  factory-follow [factory_address] - 实时监听 Factory 事件"
    echo "  position-follow [position_manager_address] - 实时监听 Position Manager 事件"
    echo "  all-follow                     - 实时监听所有事件"
    echo "  decode-logs [log_file]         - 解码日志文件"
    echo "  help, -h, --help               - 显示此帮助信息"
    echo ""
    echo "实时监听功能:"
    echo "  - 使用 --follow 参数持续监听新事件"
    echo "  - 自动解码事件参数"
    echo "  - 显示人类可读的事件信息"
    echo ""
    echo "示例:"
    echo "  $0 pool-follow 0x1234...     # 实时监听特定 Pool 事件"
    echo "  $0 all-follow                # 实时监听所有事件"
    echo "  $0 decode-logs events.log    # 解码日志文件"
    echo "  $0 help                      # 显示帮助信息"
}

# 实时监听 Pool 事件
monitor_pool_follow() {
    local pool_address=${1:-$FACTORY_ADDRESS}
    echo "实时监听 Pool 事件: $pool_address"
    echo "按 Ctrl+C 停止监听"
    echo ""

    # 使用 cast logs --follow 实时监听
    cast logs --follow --address "$pool_address" \
        --rpc-url "$RPC_URL" 2>/dev/null | while read -r line; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
        
        # 尝试解码事件
        if [[ $line == *"topics:"* ]]; then
            decode_event_log "$line"
        fi
    done
}

# 实时监听 Factory 事件
monitor_factory_follow() {
    local factory_address=${1:-$FACTORY_ADDRESS}
    echo "实时监听 Factory 事件: $factory_address"
    echo "按 Ctrl+C 停止监听"
    echo ""

    cast logs --follow --address "$factory_address" \
        --rpc-url "$RPC_URL" 2>/dev/null | while read -r line; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
        
        if [[ $line == *"topics:"* ]]; then
            decode_event_log "$line"
        fi
    done
}

# 实时监听 Position Manager 事件
monitor_position_follow() {
    local position_manager_address=${1:-$POSITION_MANAGER_ADDRESS}
    echo "实时监听 Position Manager 事件: $position_manager_address"
    echo "按 Ctrl+C 停止监听"
    echo ""

    cast logs --follow --address "$position_manager_address" \
        --rpc-url "$RPC_URL" 2>/dev/null | while read -r line; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
        
        if [[ $line == *"topics:"* ]]; then
            decode_event_log "$line"
        fi
    done
}

# 实时监听所有事件
monitor_all_follow() {
    echo "实时监听所有 Uniswap V3 事件..."
    echo "按 Ctrl+C 停止监听"
    echo ""

    # 获取 Pool 地址
    local pool_address=$(cast call "$FACTORY_ADDRESS" "getPool(address,address,uint24)" \
        "$WETH_ADDRESS" "$PQUSD_ADDRESS" "3000" --rpc-url "$RPC_URL" 2>/dev/null || echo "")

    if [ -n "$pool_address" ] && [ "$pool_address" != "0x0000000000000000000000000000000000000000" ]; then
        echo "找到 Pool 地址: $pool_address"
        echo "监听 Pool 事件..."
        monitor_pool_follow "$pool_address" &
        local pool_pid=$!
    fi

    echo "监听 Factory 事件..."
    monitor_factory_follow &
    local factory_pid=$!

    echo "监听 Position Manager 事件..."
    monitor_position_follow &
    local position_pid=$!

    # 等待所有进程
    wait $pool_pid $factory_pid $position_pid 2>/dev/null || true
}

# 解码事件日志
decode_event_log() {
    local log_line="$1"
    
    # 提取 topics 和 data
    local topics=$(echo "$log_line" | grep -o 'topics: \[.*\]' | sed 's/topics: \[//;s/\]//')
    local data=$(echo "$log_line" | grep -o 'data: 0x[0-9a-fA-F]*')
    
    if [ -n "$topics" ] && [ -n "$data" ]; then
        echo "  -> 事件解码:"
        echo "     Topics: $topics"
        echo "     Data: $data"
        
        # 根据第一个 topic 判断事件类型
        local topic0=$(echo "$topics" | cut -d',' -f1 | tr -d ' ')
        decode_by_topic "$topic0" "$data"
    fi
}

# 根据 topic 解码事件
decode_by_topic() {
    local topic0="$1"
    local data="$2"
    
    # 常见事件签名
    case "$topic0" in
        "0x783cca1c") # Initialize(uint160,int24)
            echo "     -> Initialize 事件"
            ;;
        "0x7a53080a") # Mint(address,address,int24,int24,uint128,uint256,uint256)
            echo "     -> Mint 事件"
            ;;
        "0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67") # Swap(address,address,int256,int256,uint160,uint128,int24)
            echo "     -> Swap 事件"
            ;;
        "0x0c396cd989a39f4459b5fa1aed6a9a8d78bcbe3f0db2a6e0f8b0b5b5b5b5b5b5") # Burn(address,int24,int24,uint128,uint256,uint256)
            echo "     -> Burn 事件"
            ;;
        "0x70935338e2e134f9bf25aa7ffb05934a17c32e75b111c19a1f33d309c2b236c5") # Collect(address,address,int24,int24,uint128,uint128)
            echo "     -> Collect 事件"
            ;;
        "0xbdbd71bb") # Flash(address,address,uint256,uint256,uint256,uint256)
            echo "     -> Flash 事件"
            ;;
        "0x783cca1c") # PoolCreated(address,address,uint24,int24,address)
            echo "     -> PoolCreated 事件"
            ;;
        "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0") # OwnerChanged(address,address)
            echo "     -> OwnerChanged 事件"
            ;;
        "0x3067048beee31b25b2f1681f88dac838c8bba36af25bfb2b7cf73a2f605f770d") # IncreaseLiquidity(uint256,uint128,uint256,uint256)
            echo "     -> IncreaseLiquidity 事件"
            ;;
        "0x26f6a048ee9138f2c0ce266f322cb99228e8d619ae2a3349e2b3e6c4e3f4b8f") # DecreaseLiquidity(uint256,uint128,uint256,uint256)
            echo "     -> DecreaseLiquidity 事件"
            ;;
        "0x40d0efd1a0d293c590e9c90f8c2e8087c8f94b01ff0f130177d466a810ff9d1f") # Collect(uint256,address,uint256,uint256)
            echo "     -> Position Collect 事件"
            ;;
        *)
            echo "     -> 未知事件类型"
            ;;
    esac
}

# 解码日志文件
decode_logs() {
    local log_file="$1"
    
    if [ -z "$log_file" ]; then
        echo "错误: 需要提供日志文件路径"
        echo "使用方法: $0 decode-logs <log_file>"
        exit 1
    fi
    
    if [ ! -f "$log_file" ]; then
        echo "错误: 日志文件不存在: $log_file"
        exit 1
    fi
    
    echo "解码日志文件: $log_file"
    echo ""
    
    while IFS= read -r line; do
        if [[ $line == *"topics:"* ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"
            decode_event_log "$line"
            echo ""
        fi
    done < "$log_file"
}

# 主函数
main() {
    load_env
    check_env_vars

    if [ -z "$RPC_URL" ]; then
        echo "警告: RPC_URL 未设置，使用默认值 http://localhost:8545"
        export RPC_URL="http://localhost:8545"
    fi

    case "${1:-help}" in
        "pool-follow")
            monitor_pool_follow "$2"
            ;;
        "factory-follow")
            monitor_factory_follow "$2"
            ;;
        "position-follow")
            monitor_position_follow "$2"
            ;;
        "all-follow")
            monitor_all_follow
            ;;
        "decode-logs")
            decode_logs "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "错误: 未知参数 '$1'"
            show_help
            exit 1
            ;;
    esac
}

main "$@" 