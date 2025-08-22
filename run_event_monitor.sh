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
    echo "Uniswap V3 事件监听脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [选项] [合约地址]"
    echo ""
    echo "选项:"
    echo "  pool-events [pool_address]     - 监听 Pool 事件"
    echo "  factory-events [factory_address] - 监听 Factory 事件"
    echo "  position-events [position_manager_address] - 监听 Position Manager 事件"
    echo "  router-events [router_address] - 监听 Router 事件"
    echo "  quoter-events [quoter_address] - 监听 QuoterV2 事件"
    echo "  token-events [token_address]   - 监听代币事件"
    echo "  all-events                     - 监听所有事件"
    echo "  decode-event [event_signature] [log_data] - 解码特定事件"
    echo "  help, -h, --help               - 显示此帮助信息"
    echo ""
    echo "事件类型:"
    echo "  Pool 事件:"
    echo "    - Initialize: 池初始化"
    echo "    - Mint: 添加流动性"
    echo "    - Burn: 移除流动性"
    echo "    - Swap: 代币交换"
    echo "    - Collect: 收集费用"
    echo "    - Flash: 闪电贷"
    echo "    - IncreaseObservationCardinalityNext: 增加观察基数"
    echo "    - SetFeeProtocol: 设置协议费用"
    echo "    - CollectProtocol: 收集协议费用"
    echo ""
    echo "  Factory 事件:"
    echo "    - PoolCreated: 池创建"
    echo "    - OwnerChanged: 所有者变更"
    echo "    - FeeAmountEnabled: 启用费用金额"
    echo ""
    echo "  Position Manager 事件:"
    echo "    - IncreaseLiquidity: 增加流动性"
    echo "    - DecreaseLiquidity: 减少流动性"
    echo "    - Collect: 收集费用"
    echo ""
    echo "  ERC20 事件:"
    echo "    - Transfer: 转账"
    echo "    - Approval: 授权"
    echo ""
    echo "  ERC721 事件:"
    echo "    - Transfer: 转账"
    echo "    - Approval: 授权"
    echo "    - ApprovalForAll: 全局授权"
    echo ""
    echo "示例:"
    echo "  $0 pool-events 0x1234...     # 监听特定 Pool 事件"
    echo "  $0 all-events                # 监听所有事件"
    echo "  $0 decode-event 0x... 0x...  # 解码特定事件"
    echo "  $0 help                      # 显示帮助信息"
}

# 监听 Pool 事件
monitor_pool_events() {
    local pool_address=${1:-$FACTORY_ADDRESS}
    echo "监听 Pool 事件: $pool_address"
    echo ""

    # Initialize 事件
    echo "=== Initialize 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$pool_address" \
        --event "Initialize(uint160,int24)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 Initialize 事件"

    # Mint 事件
    echo ""
    echo "=== Mint 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$pool_address" \
        --event "Mint(address,address,int24,int24,uint128,uint256,uint256)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 Mint 事件"

    # Swap 事件
    echo ""
    echo "=== Swap 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$pool_address" \
        --event "Swap(address,address,int256,int256,uint160,uint128,int24)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 Swap 事件"

    # Burn 事件
    echo ""
    echo "=== Burn 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$pool_address" \
        --event "Burn(address,int24,int24,uint128,uint256,uint256)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 Burn 事件"

    # Collect 事件
    echo ""
    echo "=== Collect 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$pool_address" \
        --event "Collect(address,address,int24,int24,uint128,uint128)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 Collect 事件"

    # Flash 事件
    echo ""
    echo "=== Flash 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$pool_address" \
        --event "Flash(address,address,uint256,uint256,uint256,uint256)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 Flash 事件"

    # IncreaseObservationCardinalityNext 事件
    echo ""
    echo "=== IncreaseObservationCardinalityNext 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$pool_address" \
        --event "IncreaseObservationCardinalityNext(uint16,uint16)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 IncreaseObservationCardinalityNext 事件"

    # SetFeeProtocol 事件
    echo ""
    echo "=== SetFeeProtocol 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$pool_address" \
        --event "SetFeeProtocol(uint8,uint8,uint8,uint8)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 SetFeeProtocol 事件"

    # CollectProtocol 事件
    echo ""
    echo "=== CollectProtocol 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$pool_address" \
        --event "CollectProtocol(address,address,uint128,uint128)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 CollectProtocol 事件"
}

# 监听 Factory 事件
monitor_factory_events() {
    local factory_address=${1:-$FACTORY_ADDRESS}
    echo "监听 Factory 事件: $factory_address"
    echo ""

    # PoolCreated 事件
    echo "=== PoolCreated 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$factory_address" \
        --event "PoolCreated(address,address,uint24,int24,address)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 PoolCreated 事件"

    # OwnerChanged 事件
    echo ""
    echo "=== OwnerChanged 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$factory_address" \
        --event "OwnerChanged(address,address)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 OwnerChanged 事件"

    # FeeAmountEnabled 事件
    echo ""
    echo "=== FeeAmountEnabled 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$factory_address" \
        --event "FeeAmountEnabled(uint24,int24)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 FeeAmountEnabled 事件"
}

# 监听 Position Manager 事件
monitor_position_events() {
    local position_manager_address=${1:-$POSITION_MANAGER_ADDRESS}
    echo "监听 Position Manager 事件: $position_manager_address"
    echo ""

    # IncreaseLiquidity 事件
    echo "=== IncreaseLiquidity 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$position_manager_address" \
        --event "IncreaseLiquidity(uint256,uint128,uint256,uint256)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 IncreaseLiquidity 事件"

    # DecreaseLiquidity 事件
    echo ""
    echo "=== DecreaseLiquidity 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$position_manager_address" \
        --event "DecreaseLiquidity(uint256,uint128,uint256,uint256)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 DecreaseLiquidity 事件"

    # Collect 事件
    echo ""
    echo "=== Collect 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$position_manager_address" \
        --event "Collect(uint256,address,uint256,uint256)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 Collect 事件"
}

# 监听 Router 事件
monitor_router_events() {
    local router_address=${1:-$SWAP_ROUTER_ADDRESS}
    echo "监听 Router 事件: $router_address"
    echo ""

    # Router 本身可能不发出特定事件，但会调用 Pool 的 Swap 事件
    echo "Router 通常不直接发出事件，而是调用 Pool 的 Swap 事件"
    echo "请使用 pool-events 选项来查看交换事件"
}

# 监听 QuoterV2 事件
monitor_quoter_events() {
    local quoter_address=${1:-$QUOTER_V2_ADDRESS}
    echo "监听 QuoterV2 事件: $quoter_address"
    echo ""

    # QuoterV2 通常不发出事件，但可以监听其调用
    echo "QuoterV2 通常不直接发出事件，但可以监听其调用"
    echo "请使用 pool-events 选项来查看相关的交换事件"
}

# 监听代币事件
monitor_token_events() {
    local token_address=${1:-$WETH_ADDRESS}
    echo "监听代币事件: $token_address"
    echo ""

    # ERC20 Transfer 事件
    echo "=== ERC20 Transfer 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$token_address" \
        --event "Transfer(address,address,uint256)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 Transfer 事件"

    # ERC20 Approval 事件
    echo ""
    echo "=== ERC20 Approval 事件 ==="
    cast logs --from-block latest-1000 --to-block latest \
        --address "$token_address" \
        --event "Approval(address,address,uint256)" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "无 Approval 事件"
}

# 监听所有事件
monitor_all_events() {
    echo "监听所有 Uniswap V3 事件..."
    echo ""

    # 获取 Pool 地址
    local pool_address=$(cast call "$FACTORY_ADDRESS" "getPool(address,address,uint24)" \
        "$WETH_ADDRESS" "$PQUSD_ADDRESS" "3000" --rpc-url "$RPC_URL" 2>/dev/null || echo "")

    if [ -n "$pool_address" ] && [ "$pool_address" != "0x0000000000000000000000000000000000000000" ]; then
        echo "找到 Pool 地址: $pool_address"
        echo ""
        monitor_pool_events "$pool_address"
    else
        echo "未找到 Pool 地址，跳过 Pool 事件监听"
    fi

    echo ""
    monitor_factory_events
    echo ""
    monitor_position_events
    echo ""
    monitor_router_events
    echo ""
    monitor_quoter_events
    echo ""
    monitor_token_events "$WETH_ADDRESS"
    echo ""
    monitor_token_events "$PQUSD_ADDRESS"
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
        "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef") # Transfer(address,address,uint256)
            echo "     -> ERC20 Transfer 事件"
            ;;
        "0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925") # Approval(address,address,uint256)
            echo "     -> ERC20 Approval 事件"
            ;;
        *)
            echo "     -> 未知事件类型"
            ;;
    esac
}

# 解码特定事件
decode_event() {
    local event_signature="$1"
    local log_data="$2"
    
    if [ -z "$event_signature" ] || [ -z "$log_data" ]; then
        echo "错误: 需要提供事件签名和日志数据"
        echo "使用方法: $0 decode-event <event_signature> <log_data>"
        exit 1
    fi

    echo "解码事件:"
    echo "事件签名: $event_signature"
    echo "日志数据: $log_data"
    echo ""

    # 使用 cast 解码事件
    cast --to-ascii "$log_data" 2>/dev/null || echo "无法解码为 ASCII"
    echo ""
    cast --to-dec "$log_data" 2>/dev/null || echo "无法解码为十进制"
    echo ""
    cast --to-hex "$log_data" 2>/dev/null || echo "无法解码为十六进制"
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
        "pool-events")
            monitor_pool_events "$2"
            ;;
        "factory-events")
            monitor_factory_events "$2"
            ;;
        "position-events")
            monitor_position_events "$2"
            ;;
        "router-events")
            monitor_router_events "$2"
            ;;
        "quoter-events")
            monitor_quoter_events "$2"
            ;;
        "token-events")
            monitor_token_events "$2"
            ;;
        "all-events")
            monitor_all_events
            ;;
        "decode-event")
            decode_event "$2" "$3"
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