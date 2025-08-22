#!/bin/bash

# 流动性管理脚本运行器
# 使用方法: ./run_liquidity_management.sh

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
    local required_vars=("PRIVATE_KEY" "WETH_ADDRESS" "PQUSD_ADDRESS" "POSITION_MANAGER_ADDRESS" "FACTORY_ADDRESS")
    
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
    echo "流动性管理脚本运行器"
    echo ""
    echo "使用方法:"
    echo "  $0 [操作]"
    echo ""
    echo "操作选项:"
    echo "  all              # 运行完整流程"
    echo "  mint             # 仅添加流动性"
    echo "  increase         # 仅增加流动性"
    echo "  collect          # 仅收集费用"
    echo "  decrease         # 仅减少流动性"
    echo "  burn             # 仅销毁位置"
    echo "  balance          # 查询余额和流动性状态"
    echo "  help, -h, --help # 显示此帮助信息"
    echo ""
    echo "功能说明:"
    echo "  完整流程包括:"
    echo "  1. 添加流动性 (mint)"
    echo "  2. 增加流动性 (increaseLiquidity)"
    echo "  3. 收集费用 (collect)"
    echo "  4. 减少流动性 (decreaseLiquidity)"
    echo "  5. 销毁位置 (burn)"
    echo ""
    echo "示例:"
    echo "  $0 mint         # 仅添加流动性"
    echo "  $0 collect      # 仅收集费用"
    echo "  $0 all          # 运行完整流程"
    echo "  $0 help         # 显示帮助信息"
}

# 运行流动性管理流程
run_liquidity_management() {
    local operation=${1:-"all"}
    
    case $operation in
        "all")
            echo "运行完整流动性管理流程..."
            echo "执行步骤:"
            echo "1. 添加流动性"
            echo "2. 增加流动性"
            echo "3. 收集费用"
            echo "4. 减少流动性"
            echo "5. 销毁位置"
            echo ""
            forge script script/liquidityManagement.s.sol:LiquidityManagement --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            ;;
        "mint")
            echo "仅添加流动性..."
            echo "执行 mint 操作，请等待..."
            
            # 执行 mint 操作并捕获输出
            MINT_OUTPUT=$(forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runMint()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 2>&1)
            MINT_EXIT_CODE=$?
            
            if [ $MINT_EXIT_CODE -eq 0 ]; then
                echo "✅ Mint 操作执行成功"
                
                # 从输出中提取 CREATED_TOKEN_ID
                TOKEN_ID=$(echo "$MINT_OUTPUT" | grep -A 2 "=== TOKEN_ID_FOR_ENV ===" | grep -v "=== TOKEN_ID_FOR_ENV ===" | grep -v "=== END_TOKEN_ID_FOR_ENV ===" | grep -v "^$" | head -1)
                
                if [ -n "$TOKEN_ID" ]; then
                    echo "📝 提取到 TOKEN_ID: $TOKEN_ID"
                    
                    # 更新 .env 文件
                    if [ -f ".env" ]; then
                        # 如果已存在 CREATED_TOKEN_ID，则更新；否则添加
                        if grep -q "CREATED_TOKEN_ID" .env; then
                            sed -i '' "s/CREATED_TOKEN_ID=.*/CREATED_TOKEN_ID=$TOKEN_ID/" .env
                            echo "✅ 已更新 .env 文件中的 CREATED_TOKEN_ID"
                        else
                            echo "CREATED_TOKEN_ID=$TOKEN_ID" >> .env
                            echo "✅ 已在 .env 文件中添加 CREATED_TOKEN_ID"
                        fi
                    else
                        echo "⚠️  未找到 .env 文件，无法更新 TOKEN_ID"
                    fi
                else
                    echo "⚠️  未能从输出中提取 TOKEN_ID"
                fi
                
                echo ""
                echo "📋 Mint 操作输出:"
                echo "$MINT_OUTPUT"
            else
                echo "❌ Mint 操作执行失败"
                echo "错误输出:"
                echo "$MINT_OUTPUT"
                exit 1
            fi
            ;;
        "increase")
            echo "仅增加流动性..."
            forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runIncreaseLiquidity()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            ;;
        "collect")
            echo "仅收集费用..."
            forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runCollectFees()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            ;;
        "decrease")
            echo "仅减少流动性..."
            forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runDecreaseLiquidity()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            ;;
        "burn")
            echo "仅销毁位置..."
            forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runBurnPosition()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            ;;
        "balance")
            echo "查询余额和流动性状态..."
            forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runQueryBalance()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
            ;;
        *)
            echo "错误: 未知操作 '$operation'"
            show_help
            exit 1
            ;;
    esac
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
        echo "错误: 请指定要执行的操作"
        echo ""
        show_help
        exit 1
    else
        case $1 in
            "help"|"-h"|"--help")
                show_help
                ;;
            "all"|"mint"|"increase"|"collect"|"decrease"|"burn"|"balance")
                run_liquidity_management "$1"
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