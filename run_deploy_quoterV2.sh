#!/bin/bash

# QuoterV2 Deployment Script
# Usage: ./run_deploy_quoterV2.sh [operation]

set -e

# Load .env file
load_env() {
    if [ -f ".env" ]; then
        echo "Loading environment variables from .env file..."
        export $(cat .env | grep -v '^#' | xargs)
    else
        echo "Warning: .env file not found"
    fi
}

# Check environment variables
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

# Show help information
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
    echo "  $0 test 5   # Test with amountIn = 5"
}

# Deploy QuoterV2
deploy_quoterV2() {
    echo "Deploying QuoterV2..."
    forge script script/deployQuoterV2.s.sol:DeployQuoterV2 --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 
}

# Verify deployment
verify_quoterV2() {
    if [ -z "$QUOTER_V2_ADDRESS" ]; then
        echo "Error: QUOTER_V2_ADDRESS not set"
        echo "Please set QUOTER_V2_ADDRESS environment variable"
        exit 1
    fi
    
    echo "Verifying QuoterV2 deployment..."
    forge script script/deployQuoterV2.s.sol:DeployQuoterV2 --sig "verifyQuoterV2()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --legacy  
}

# Test functionality
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
    
    # Get amountIn parameter, use default value 1 if not provided
    local amountIn=${1:-1}
    echo "Testing QuoterV2 functionality with amountIn: $amountIn"
    forge script script/deployQuoterV2.s.sol:DeployQuoterV2 --sig "testQuoterV2(uint256)" $amountIn --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 
}

# Main function
main() {
    # Load .env file
    load_env
    
    # Check environment variables
    check_env_vars
    
    # Check RPC_URL
    if [ -z "$RPC_URL" ]; then
        echo "Warning: RPC_URL not set, using default http://localhost:8545"
        export RPC_URL="http://localhost:8545"
    fi
    
    # Process parameters
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
            # Pass amountIn parameter to test_quoterV2 function
            shift  # Remove "test" parameter
            test_quoterV2 "$@"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "Error: Unknown operation '$operation'"
            show_help
            ;;
    esac
}

# Run main function
main "$@"