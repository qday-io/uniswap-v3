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
    echo "  deploy      - Deploy QuoterV2 contract and update .env file"
    echo "  verify      - Verify QuoterV2 deployment"
    echo "  test        - Test QuoterV2 functionality"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy   # Deploy QuoterV2 and update .env"
    echo "  $0 verify   # Verify deployment"
    echo "  $0 test     # Test functionality"
    echo "  $0 test 5   # Test with amountIn = 5"
    echo ""
    echo "Note: After successful deployment, QUOTER_V2_ADDRESS will be automatically"
    echo "      updated in your .env file."
}

# Deploy QuoterV2
deploy_quoterV2() {
    echo "Deploying QuoterV2..."
    
    # Deploy and capture output
    local deploy_output
    deploy_output=$(forge script script/deployQuoterV2.s.sol:DeployQuoterV2 --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 2>&1)
    
    # Check if deployment was successful
    if [ $? -eq 0 ]; then
        echo "QuoterV2 deployment successful!"
        
        # Try multiple methods to extract contract address
        local quoter_v2_address
        
        # Method 1: Try to extract from script output
        quoter_v2_address=$(echo "$deploy_output" | grep "QuoterV2 deployed at:" | awk '{print $NF}' | tr -d ':')
        
        # Method 2: If Method 1 failed, try to extract from broadcast logs
        if [ -z "$quoter_v2_address" ] || [ "$quoter_v2_address" = "0x0000000000000000000000000000000000000000" ]; then
            echo "Trying to extract address from broadcast logs..."
            
            # Look for the most recent deployment in broadcast logs
            local latest_broadcast
            latest_broadcast=$(ls -t broadcast/*/latest/*.json 2>/dev/null | head -1)
            
            if [ -n "$latest_broadcast" ]; then
                echo "Found broadcast log: $latest_broadcast"
                
                # Extract contract address from broadcast log
                quoter_v2_address=$(jq -r '.transactions[] | select(.transactionType == "CREATE") | .contractAddress' "$latest_broadcast" 2>/dev/null | grep -v "null" | head -1)
                
                if [ -n "$quoter_v2_address" ] && [ "$quoter_v2_address" != "null" ]; then
                    echo "Extracted address from broadcast log: $quoter_v2_address"
                fi
            fi
        fi
        
        # Method 3: If still no address, try to find it in the deployment output
        if [ -z "$quoter_v2_address" ] || [ "$quoter_v2_address" = "0x0000000000000000000000000000000000000000" ]; then
            echo "Trying to extract address from deployment output..."
            
            # Look for any address pattern in the output
            quoter_v2_address=$(echo "$deploy_output" | grep -o "0x[a-fA-F0-9]\{40\}" | tail -1)
            
            if [ -n "$quoter_v2_address" ]; then
                echo "Extracted address from output: $quoter_v2_address"
            fi
        fi
        
        # Final validation and update
        if [ -n "$quoter_v2_address" ] && [ "$quoter_v2_address" != "0x0000000000000000000000000000000000000000" ]; then
            echo "QuoterV2 deployed at: $quoter_v2_address"
            
            # Update .env file
            update_env_file "$quoter_v2_address"
        else
            echo "Warning: Could not extract QuoterV2 address from deployment output"
            echo "Please manually check the deployment output and update .env file"
            echo "Deployment output:"
            echo "$deploy_output"
        fi
    else
        echo "QuoterV2 deployment failed!"
        echo "$deploy_output"
        exit 1
    fi
}

# Update .env file with QuoterV2 address
update_env_file() {
    local quoter_v2_address=$1
    
    if [ -f ".env" ]; then
        echo "Updating .env file with QUOTER_V2_ADDRESS..."
        
        # Backup original file
        cp ".env" ".env.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Update or add QUOTER_V2_ADDRESS (Linux compatible)
        if grep -q "QUOTER_V2_ADDRESS" .env; then
            # Update existing QUOTER_V2_ADDRESS
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                sed -i '' "s/QUOTER_V2_ADDRESS=.*/QUOTER_V2_ADDRESS=$quoter_v2_address/" .env
            else
                # Linux
                sed -i "s/QUOTER_V2_ADDRESS=.*/QUOTER_V2_ADDRESS=$quoter_v2_address/" .env
            fi
            echo "Updated QUOTER_V2_ADDRESS in .env file"
        else
            # Add new QUOTER_V2_ADDRESS
            echo "QUOTER_V2_ADDRESS=$quoter_v2_address" >> .env
            echo "Added QUOTER_V2_ADDRESS to .env file"
        fi
        
        echo "✅ .env file updated successfully"
        echo "   QUOTER_V2_ADDRESS: $quoter_v2_address"
        
        # Export the variable for current session
        export QUOTER_V2_ADDRESS="$quoter_v2_address"
    else
        echo "Warning: .env file not found, cannot update QUOTER_V2_ADDRESS"
        echo "Please manually add QUOTER_V2_ADDRESS=$quoter_v2_address to your .env file"
    fi
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