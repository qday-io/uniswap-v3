#!/bin/bash

# WETH Deposit 脚本运行器
# 使用方法: ./run_weth_deposit.sh

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
    local required_vars=("PRIVATE_KEY" "WETH_ADDRESS")
    
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
    echo "WETH Deposit 脚本运行器"
    echo ""
    echo "使用方法:"
    echo "  $0"
    echo ""
    echo "功能:"
    echo "  执行 WETH deposit 操作，数额为 1000 * 10^18 wei (1000 ETH)"
    echo ""
    echo "选项:"
    echo "  help, -h, --help  - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0              # 执行 WETH deposit"
    echo "  $0 help         # 显示帮助信息"
}

# 运行 WETH deposit
run_weth_deposit() {
    echo "执行 WETH deposit 操作..."
    echo "Deposit 数额: 1000 * 10^18 wei (1000 ETH)"
    echo ""
    
    forge script script/wethDeposit.s.sol:WETHDeposit --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
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
        run_weth_deposit
    else
        case $1 in
            "help"|"-h"|"--help")
                show_help
                ;;
            *)
                echo "错误: 未知参数 '$1'"
                show_help
                exit 1
                ;;
        esac
    fi
}

# 运行主函数
main "$@" 