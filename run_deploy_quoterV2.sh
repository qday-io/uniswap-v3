#!/bin/bash

# QuoterV2 部署脚本
# 使用方法: ./run_deploy_quoterV2.sh [operation]

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
    local required_vars=("PRIVATE_KEY" "FACTORY_ADDRESS" "WETH_ADDRESS")
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "Error: Environment variable $var is not set"
            echo "Please ensure all required environment variables are set in .env file or environment"
            exit 1
        fi
    done
}

# 显示帮助信息
show_help() {
    echo "QuoterV2 Deployment Script"
    echo ""
    echo "Usage:"
    echo "  $0 [operation]"
    echo ""
    echo "Operations:"
    echo "  deploy      - Deploy QuoterV2 contract"
    echo "  verify      - Verify QuoterV2 deployment"
    echo "  test        - Test QuoterV2 functionality"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy   # Deploy QuoterV2"
    echo "  $0 verify   # Verify deployment"
    echo "  $0 test     # Test functionality"
}

# 部署 QuoterV2
deploy_quoterV2() {
    echo "Deploying QuoterV2..."
    forge script script/deployQuoterV2.s.sol:DeployQuoterV2 --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 
}

# 验证部署
verify_quoterV2() {
    if [ -z "$QUOTER_V2_ADDRESS" ]; then
        echo "Error: QUOTER_V2_ADDRESS not set"
        echo "Please set QUOTER_V2_ADDRESS environment variable"
        exit 1
    fi
    
    echo "Verifying QuoterV2 deployment..."
    forge script script/deployQuoterV2.s.sol:DeployQuoterV2 --sig "verifyQuoterV2()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --legacy  
}

# 测试功能
test_quoterV2() {
    if [ -z "$QUOTER_V2_ADDRESS" ]; then
        echo "Error: QUOTER_V2_ADDRESS not set"
        echo "Please set QUOTER_V2_ADDRESS environment variable"
        exit 1
    fi
    
    if [ -z "$PQUSD_ADDRESS" ]; then
        echo "Error: PQUSD_ADDRESS not set"
        echo "Please set PQUSD_ADDRESS environment variable"
        exit 1
    fi
    
    echo "Testing QuoterV2 functionality..."
    forge script script/deployQuoterV2.s.sol:DeployQuoterV2 --sig "testQuoterV2()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 
}

# 主函数
main() {
    # 加载 .env 文件
    load_env
    
    # 检查环境变量
    check_env_vars
    
    # 检查 RPC_URL
    if [ -z "$RPC_URL" ]; then
        echo "Warning: RPC_URL not set, using default http://localhost:8545"
        export RPC_URL="http://localhost:8545"
    fi
    
    # 处理参数
    if [ $# -eq 0 ]; then
        echo "Error: Please specify an operation"
        show_help
        exit 1
    fi
    
    local operation=$1
    
    case $operation in
        "deploy")
            deploy_quoterV2
            ;;
        "verify")
            verify_quoterV2
            ;;
        "test")
            test_quoterV2
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "Error: Unknown operation '$operation'"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@" 