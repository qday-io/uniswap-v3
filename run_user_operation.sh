#!/bin/bash

# User Operation Script Runner
# Usage: ./run_user_operation.sh [operation]

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
    local required_vars=("PRIVATE_KEY" "WETH_ADDRESS" "PQUSD_ADDRESS" "SWAP_ROUTER_ADDRESS" "POSITION_MANAGER_ADDRESS" "FACTORY_ADDRESS")
    
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
    echo "User Operation Script Runner"
    echo ""
    echo "Usage:"
    echo "  $0 [operation]"
    echo ""
    echo "Operation options:"
    echo "  swap          - Execute WETH -> PQUSD swap"
    echo "  swap-reverse  - Execute PQUSD -> WETH swap"
    echo "  balance       - Query user balance"
    echo "  pool-info     - Query pool information"
    echo "  liquidity-status - Query liquidity status"
    echo "  help          - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 swap           # Execute token swap (default 1 ETH)"
    echo "  $0 swap 5         # Execute token swap (5 ETH)"
    echo "  $0 swap-reverse   # Execute reverse swap (default 1 ETH)"
    echo "  $0 swap-reverse 100 # Execute reverse swap (100 PQUSD)"
    echo "  $0 balance        # Query balance"
    echo "  $0 pool-info      # Query pool information"
}

# Run user operation
run_operation() {
    local operation=$1
    local amount_in=${2:-1} # Default value is 1 ETH
    local function_name=""
    local forge_args=""
    
    case $operation in
        "swap")
            function_name="swapTokens(uint256)"
            forge_args="$amount_in"
            ;;
        "swap-reverse")
            function_name="swapTokensReverse(uint256)"
            forge_args="$amount_in"
            ;;
        "balance")
            function_name="checkUserBalance()"
            ;;
        "pool-info")
            function_name="checkPoolInfo()"
            ;;
        "liquidity-status")
            function_name="checkLiquidityStatus()"
            ;;
        *)
            echo "Error: Unknown operation '$operation'"
            show_help
            exit 1
            ;;
    esac
    
    echo "Executing user operation: $operation"
    if [ -n "$forge_args" ]; then
        echo "Swap amount: $amount_in ETH"
        forge script script/useOperation.s.sol:UseOperation --sig "$function_name" $forge_args --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 
    else
        forge script script/useOperation.s.sol:UseOperation --sig "$function_name" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 
    fi
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
        "swap"|"swap-reverse")
            # For swap operations, pass the second parameter (amountIn)
            local amount_in=${2:-1}
            run_operation $operation $amount_in
            ;;
        "balance"|"pool-info"|"liquidity-status")
            run_operation $operation
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

# Run main function
main "$@" 