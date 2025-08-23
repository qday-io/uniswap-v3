#!/bin/bash

# Liquidity Management Script Runner
# Usage: ./run_liquidity_management.sh

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
    local required_vars=("PRIVATE_KEY" "WETH_ADDRESS" "PQUSD_ADDRESS" "POSITION_MANAGER_ADDRESS" "FACTORY_ADDRESS")
    
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
    echo "Liquidity Management Script Runner"
    echo ""
    echo "Usage:"
    echo "  $0 [operation]"
    echo ""
    echo "Operation options:"
    echo "  all              # Run complete flow"
    echo "  mint             # Add liquidity only"
    echo "  increase         # Increase liquidity only (default: 50 ETH, 500 tokens)"
    echo "  increase <amount0> <amount1> # Increase liquidity with custom amounts"
    echo "  collect          # Collect fees only"
    echo "  decrease         # Decrease liquidity only"
    echo "  burn             # Burn position only"
    echo "  balance          # Query balance and liquidity status"
    echo "  help, -h, --help # Show this help message"
    echo ""
    echo "Function description:"
    echo "  Complete flow includes:"
    echo "  1. Add liquidity (mint)"
    echo "  2. Increase liquidity (increaseLiquidity)"
    echo "  3. Collect fees (collect)"
    echo "  4. Decrease liquidity (decreaseLiquidity)"
    echo "  5. Burn position (burn)"
    echo ""
    echo "Examples:"
    echo "  $0 mint                    # Add liquidity only"
    echo "  $0 increase                # Increase liquidity with default amounts"
    echo "  $0 increase 100 1000      # Increase liquidity with 100 ETH and 1000 tokens"
    echo "  $0 collect                 # Collect fees only"
    echo "  $0 all                     # Run complete flow"
    echo "  $0 help                    # Show help information"
}

# 运行流动性管理流程
run_liquidity_management() {
    local operation=${1:-"all"}
    
    case $operation in
        "all")
            echo "Running complete liquidity management flow..."
            echo "Execution steps:"
            echo "1. Add liquidity"
            echo "2. Increase liquidity"
            echo "3. Collect fees"
            echo "4. Decrease liquidity"
            echo "5. Burn position"
            echo ""
            forge script script/liquidityManagement.s.sol:LiquidityManagement --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            ;;
        "mint")
            echo "Adding liquidity only..."
            echo "Executing mint operation, please wait..."
            
            # Execute mint operation and capture output
            MINT_OUTPUT=$(forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runMint()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 2>&1)
            MINT_EXIT_CODE=$?
            
            if [ $MINT_EXIT_CODE -eq 0 ]; then
                echo "✅ Mint operation executed successfully"
                
                # Extract CREATED_TOKEN_ID from output
                TOKEN_ID=$(echo "$MINT_OUTPUT" | grep -A 2 "=== TOKEN_ID_FOR_ENV ===" | grep -v "=== TOKEN_ID_FOR_ENV ===" | grep -v "=== END_TOKEN_ID_FOR_ENV ===" | grep -v "^$" | head -1)
                
                if [ -n "$TOKEN_ID" ]; then
                    echo "📝 Extracted TOKEN_ID: $TOKEN_ID"
                    
                    # Update .env file
                    if [ -f ".env" ]; then
                        # If CREATED_TOKEN_ID already exists, update it; otherwise add it
                        if grep -q "CREATED_TOKEN_ID" .env; then
                            sed -i '' "s/CREATED_TOKEN_ID=.*/CREATED_TOKEN_ID=$TOKEN_ID/" .env
                            echo "✅ Updated CREATED_TOKEN_ID in .env file"
                        else
                            echo "CREATED_TOKEN_ID=$TOKEN_ID" >> .env
                            echo "✅ Added CREATED_TOKEN_ID to .env file"
                        fi
                    else
                        echo "⚠️  .env file not found, cannot update TOKEN_ID"
                    fi
                else
                    echo "⚠️  Could not extract TOKEN_ID from output"
                fi
                
                echo ""
                echo "📋 Mint operation output:"
                echo "$MINT_OUTPUT"
            else
                echo "❌ Mint operation failed"
                echo "Error output:"
                echo "$MINT_OUTPUT"
                exit 1
            fi
            ;;
        "increase")
            # 检查是否有额外的参数
            if [ -n "$2" ] && [ -n "$3" ]; then
                local amount0=$2
                local amount1=$3
                echo "Increasing liquidity with custom amounts: $amount0 ETH and $amount1 tokens..."
                forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runIncreaseLiquidity(uint256,uint256)" $amount0 $amount1 --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            else
                echo "Increasing liquidity with default amounts: 50 ETH and 500 tokens..."
                forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runIncreaseLiquidity()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            fi
            ;;
        "collect")
            echo "Collecting fees only..."
            forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runCollectFees()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            ;;
        "decrease")
            echo "Decreasing liquidity only..."
            forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runDecreaseLiquidity()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            ;;
        "burn")
            echo "Burning position only..."
            forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runBurnPosition()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy
            ;;
        "balance")
            echo "Querying balance and liquidity status..."
            forge script script/liquidityManagement.s.sol:LiquidityManagement --sig "runQueryBalance()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
            ;;
        *)
            echo "Error: Unknown operation '$operation'"
            show_help
            exit 1
            ;;
    esac
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
        echo "Error: Please specify an operation to execute"
        echo ""
        show_help
        exit 1
    else
        case $1 in
            "help"|"-h"|"--help")
                show_help
                ;;
            "all"|"mint"|"collect"|"decrease"|"burn"|"balance")
                run_liquidity_management "$1"
                ;;
            "increase")
                # For increase operation, pass all parameters
                run_liquidity_management "$@"
                ;;
            *)
                echo "Error: Unknown parameter '$1'"
                show_help
                exit 1
                ;;
        esac
    fi
}

# Run main function
main "$@" 