#!/bin/bash

# 用户操作脚本运行器
# 使用方法: ./run_user_operation.sh [operation]

set -e

# 加载 .env 文件
load_env() {
    if [ -f ".env" ]; then
        echo "Loading environment variables from .env file..."
        export $(cat .env | grep -v '^#' | xargs)
    else
        echo "Warning: .env file not found"
    fi
}

# 检查环境变量
check_env_vars() {
    local required_vars=("PRIVATE_KEY" "WETH_ADDRESS" "TEST_TOKEN_ADDRESS" "SWAP_ROUTER_ADDRESS" "POSITION_MANAGER_ADDRESS" "FACTORY_ADDRESS")
    
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
    echo "用户操作脚本运行器"
    echo ""
    echo "使用方法:"
    echo "  $0 [operation]"
    echo ""
    echo "操作选项:"
    echo "  swap          - 执行 WETH -> TestToken 交换"
    echo "  swap-reverse  - 执行 TestToken -> WETH 交换"
    echo "  add-liquidity - 添加流动性"
    echo "  balance       - 查询用户余额"
    echo "  pool-info     - 查询池信息"
    echo "  help          - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 swap           # 执行代币交换"
    echo "  $0 balance        # 查询余额"
    echo "  $0 pool-info      # 查询池信息"
}

# 运行用户操作
run_operation() {
    local operation=$1
    local function_name=""
    
    case $operation in
        "swap")
            function_name="swapTokens()"
            ;;
        "swap-reverse")
            function_name="swapTokensReverse()"
            ;;
        "add-liquidity")
            function_name="addUserLiquidity()"
            ;;
        "balance")
            function_name="checkUserBalance()"
            ;;
        "pool-info")
            function_name="checkPoolInfo()"
            ;;
        *)
            echo "错误: 未知操作 '$operation'"
            show_help
            exit 1
            ;;
    esac
    
    echo "执行用户操作: $operation"
    forge script script/useOperation.s.sol:UseOperation --sig "$function_name" --rpc-url $RPC_URL --broadcast
}

# 主函数
main() {
    # 加载 .env 文件
    load_env
    
    # 检查环境变量
    check_env_vars
    
    # 检查 RPC_URL
    if [ -z "$RPC_URL" ]; then
        echo "警告: RPC_URL 未设置，使用默认值 http://localhost:8545"
        export RPC_URL="http://localhost:8545"
    fi
    
    # 处理参数
    if [ $# -eq 0 ]; then
        echo "错误: 请指定操作"
        show_help
        exit 1
    fi
    
    local operation=$1
    
    case $operation in
        "swap"|"swap-reverse"|"add-liquidity"|"balance"|"pool-info")
            run_operation $operation
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "错误: 未知操作 '$operation'"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@" 