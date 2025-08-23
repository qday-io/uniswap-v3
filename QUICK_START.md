# Uniswap V3 Foundry Quick Start Guide

## 🚀 Quick Deployment

### 1. Prepare Environment

```bash
# Ensure Foundry is installed
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Clone project (if not already done)
git clone <your-repo-url>
cd uniswapV3_foundry_deployment
```

### 2. Install Dependencies

```bash
# Install all dependencies
forge install
forge build
```

### 3. Configure Environment Variables

```bash
# Copy example file
cp env.example .env

# Edit .env file
nano .env
```

In the `.env` file, set:

```bash
# Local testing (using Anvil default private key)
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://localhost:8545

# Production environment
# PRIVATE_KEY=your_private_key_here
# RPC_URL=https://sepolia.base.org
```

### 4. Start Local Node (Optional)

```bash
# Start Anvil node
anvil
```

### 5. Deploy WETH and PQUSD

```bash
# Deploy WETH and PQUSD contracts
./deploy_weth_pqusd.sh
```

### 6. Run Complete Deployment Script

```bash
# One-click Uniswap V3 deployment
./deploy_step_by_step.sh
```

### 7. Deploy QuoterV2 Contract

```bash
# Deploy QuoterV2 contract
./run_deploy_quoterV2.sh deploy

# Verify QuoterV2 deployment
./run_deploy_quoterV2.sh verify

# Test QuoterV2 functionality
./run_deploy_quoterV2.sh test
```

## 📋 Deployment Results

After deployment, you will see:

```
🎉 Uniswap V3 Foundry deployment completed!

📋 Deployment Summary:
  Factory: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
  SwapRouter: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
  NFTDescriptor: 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
  NonfungibleTokenPositionDescriptor: 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
  NonfungiblePositionManager: 0x0165878A594ca255338adfa4d48449f69242Eb8F
  WETH: 0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5
  PQUSD: 0x1984973E205CFBc454C7092d3aD051B54aB6663e
  QuoterV2: 0x8b17423CFD1882e2493983DA0dA7FD72032C67A1

📄 Detailed summary saved to: deployment_summary.md
```

## 📄 .env File Effect

After deployment, your `.env` file will contain all necessary contract addresses:

### .env File Before Deployment
```bash
# Basic configuration
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://localhost:8545

# Contract addresses (empty or placeholder before deployment)
WETH_ADDRESS=0x1234567890123456789012345678901234567890
PQUSD_ADDRESS=0x1234567890123456789012345678901234567890
POSITION_MANAGER_ADDRESS=0x1234567890123456789012345678901234567890
FACTORY_ADDRESS=0x1234567890123456789012345678901234567890
SWAP_ROUTER_ADDRESS=0x1234567890123456789012345678901234567890
QUOTER_V2_ADDRESS=0x1234567890123456789012345678901234567890
```

### .env File After Deployment
```bash
# Basic configuration
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://localhost:8545

# Token contract addresses (set by deploy_weth_pqusd.sh)
WETH_ADDRESS=0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5
PQUSD_ADDRESS=0x1984973E205CFBc454C7092d3aD051B54aB6663e

# Uniswap V3 core contract addresses (set by deploy_step_by_step.sh)
FACTORY_ADDRESS=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
SWAP_ROUTER_ADDRESS=0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
POSITION_MANAGER_ADDRESS=0x0165878A594ca255338adfa4d48449f69242Eb8F
QUOTER_V2_ADDRESS=0x8b17423CFD1882e2493983DA0dA7FD72032C67A1

# Network configuration
CHAIN_ID=31337
```

### Purpose of Environment Variables

Each environment variable has a specific purpose:

| Variable Name | Purpose | Set By Script |
|---------------|---------|---------------|
| `WETH_ADDRESS` | WETH token contract address | `deploy_weth_pqusd.sh` |
| `PQUSD_ADDRESS` | PQUSD token contract address | `deploy_weth_pqusd.sh` |
| `FACTORY_ADDRESS` | Uniswap V3 factory contract | `deploy_step_by_step.sh` |
| `SWAP_ROUTER_ADDRESS` | Swap router contract | `deploy_step_by_step.sh` |
| `POSITION_MANAGER_ADDRESS` | NFT position manager | `deploy_step_by_step.sh` |
| `QUOTER_V2_ADDRESS` | Quotation contract | `run_deploy_quoterV2.sh` |

### Verify .env File

You can use the following commands to verify if the `.env` file is correctly set:

```bash
# Load environment variables
source .env

# Check all environment variables
echo "=== Environment Variable Check ==="
echo "WETH_ADDRESS: $WETH_ADDRESS"
echo "PQUSD_ADDRESS: $PQUSD_ADDRESS"
echo "FACTORY_ADDRESS: $FACTORY_ADDRESS"
echo "SWAP_ROUTER_ADDRESS: $SWAP_ROUTER_ADDRESS"
echo "POSITION_MANAGER_ADDRESS: $POSITION_MANAGER_ADDRESS"
echo "QUOTER_V2_ADDRESS: $QUOTER_V2_ADDRESS"

# Verify contract addresses (check if contract code exists)
echo ""
echo "=== Contract Verification ==="
if [ ! -z "$WETH_ADDRESS" ] && [ "$WETH_ADDRESS" != "0x1234567890123456789012345678901234567890" ]; then
    echo "✅ WETH contract deployed: $WETH_ADDRESS"
else
    echo "❌ WETH contract not deployed or address invalid"
fi

if [ ! -z "$PQUSD_ADDRESS" ] && [ "$PQUSD_ADDRESS" != "0x1234567890123456789012345678901234567890" ]; then
    echo "✅ PQUSD contract deployed: $PQUSD_ADDRESS"
else
    echo "❌ PQUSD contract not deployed or address invalid"
fi

if [ ! -z "$FACTORY_ADDRESS" ] && [ "$FACTORY_ADDRESS" != "0x1234567890123456789012345678901234567890" ]; then
    echo "✅ Factory contract deployed: $FACTORY_ADDRESS"
else
    echo "❌ Factory contract not deployed or address invalid"
fi

# Use cast to verify contract code
echo ""
echo "=== Contract Code Verification ==="
if [ ! -z "$WETH_ADDRESS" ]; then
    WETH_CODE=$(cast code $WETH_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
    if [ "$WETH_CODE" != "0x" ] && [ ! -z "$WETH_CODE" ]; then
        echo "✅ WETH contract code exists"
    else
        echo "❌ WETH contract code does not exist"
    fi
fi

if [ ! -z "$PQUSD_ADDRESS" ]; then
    PQUSD_CODE=$(cast code $PQUSD_ADDRESS --rpc-url $RPC_URL 2>/dev/null)
    if [ "$PQUSD_CODE" != "0x" ] && [ ! -z "$PQUSD_CODE" ]; then
        echo "✅ PQUSD contract code exists"
    else
        echo "❌ PQUSD contract code does not exist"
    fi
fi
```

### Verification Examples

#### Verification Results Before Deployment
```bash
=== Environment Variable Check ===
WETH_ADDRESS: 0x1234567890123456789012345678901234567890
PQUSD_ADDRESS: 0x1234567890123456789012345678901234567890
FACTORY_ADDRESS: 0x1234567890123456789012345678901234567890

=== Contract Verification ===
❌ WETH contract not deployed or address invalid
❌ PQUSD contract not deployed or address invalid
❌ Factory contract not deployed or address invalid

=== Contract Code Verification ===
❌ WETH contract code does not exist
❌ PQUSD contract code does not exist
```

#### Verification Results After Deployment
```bash
=== Environment Variable Check ===
WETH_ADDRESS: 0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5
PQUSD_ADDRESS: 0x1984973E205CFBc454C7092d3aD051B54aB6663e
FACTORY_ADDRESS: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
QUOTER_V2_ADDRESS: 0x8b17423CFD1882e2493983DA0dA7FD72032C67A1

=== Contract Verification ===
✅ WETH contract deployed: 0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5
✅ PQUSD contract deployed: 0x1984973E205CFBc454C7092d3aD051B54aB6663e
✅ Factory contract deployed: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
✅ QuoterV2 contract deployed: 0x8b17423CFD1882e2493983DA0dA7FD72032C67A1

=== Contract Code Verification ===
✅ WETH contract code exists
✅ PQUSD contract code exists
✅ QuoterV2 contract code exists
```

## 🔧 Verify Deployment

```bash
# Verify factory contract
cast call <FACTORY_ADDRESS> "owner()" --rpc-url http://localhost:8545

# Verify router contract
cast call <ROUTER_ADDRESS> "factory()" --rpc-url http://localhost:8545

# Verify WETH contract
cast call <WETH_ADDRESS> "name()" --rpc-url http://localhost:8545

# Verify PQUSD contract
cast call <PQUSD_ADDRESS> "name()" --rpc-url http://localhost:8545

# Verify QuoterV2 contract
cast call <QUOTER_V2_ADDRESS> "factory()" --rpc-url http://localhost:8545
```

## 📁 Generated Files

- `deployment_summary.md` - Complete deployment summary
- `token_deployment_summary.md` - WETH and PQUSD deployment summary
- `*.backup` - Configuration file backups

## 🌐 Network Configuration

### Local Testing
```bash
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://localhost:8545
```

### Base Sepolia Testnet
```bash
PRIVATE_KEY=your_private_key_here
RPC_URL=https://sepolia.base.org
ETHERSCAN_API_KEY=your_api_key_here
```

### Other Networks
```bash
PRIVATE_KEY=your_private_key_here
RPC_URL=https://your_rpc_url
CHAIN_ID=your_chain_id
WETH_ADDRESS=your_weth_address
PQUSD_ADDRESS=your_pqusd_address
```

## ⚠️ Security Considerations

1. **Private Key Security**
   - Never commit `.env` file to version control
   - Use secure key management tools

2. **Network Selection**
   - Testing environment: Use Anvil or testnet
   - Production environment: Use mainnet or target network

3. **Verify Deployment**
   - Scripts automatically verify deployment
   - Recommend manual verification of key functionality

## 🆘 Troubleshooting

### Common Issues

1. **Cannot find .env file**
   ```bash
   cp env.example .env
   ```

2. **Compilation failed**
   ```bash
   forge install
   forge build
   ```

3. **Deployment failed**
   - Check if private key is correct
   - Ensure account has sufficient ETH
   - Verify RPC URL is accessible

### Redeploy

```bash
# Clean up previous deployment
rm -f deployment_summary.md
rm -f token_deployment_summary.md

# Restore backup files (if needed)
cp lib/v3-periphery/contracts/libraries/PoolAddress.sol.backup lib/v3-periphery/contracts/libraries/PoolAddress.sol
cp src/deployConstructor/SwapRouter.txt.backup src/deployConstructor/SwapRouter.txt
cp src/deployConstructor/NonfungiblePositionManager.txt.backup src/deployConstructor/NonfungiblePositionManager.txt

# Redeploy WETH and PQUSD
./deploy_weth_pqusd.sh

# Re-run complete deployment script
./deploy_step_by_step.sh

# Redeploy QuoterV2
./run_deploy_quoterV2.sh deploy
```

## 🧪 Test Features

After deployment, you can test various features:

```bash
# Check contract configuration
./check_weth_pqusd.sh

# Test user operations
./run_user_operation.sh balance
./run_user_operation.sh swap 5          # Swap 5 ETH
./run_user_operation.sh swap-reverse 100 # Swap 100 PQUSD

# Test liquidity management
./run_liquidity_management.sh mint
./run_liquidity_management.sh increase 100 1000  # 100 ETH, 1000 tokens
./run_liquidity_management.sh collect
./run_liquidity_management.sh balance

# Test QuoterV2
./run_deploy_quoterV2.sh test 5        # Test with 5 ETH

# Test WETH deposit
./run_weth_deposit.sh
```

## 📡 Advanced Features

### Event Monitoring
```bash
# Monitor all events
./run_event_monitor.sh all-events

# Real-time monitoring
./run_realtime_monitor.sh all-follow

# Monitor specific contract events
./run_event_monitor.sh pool-events <pool_address>
./run_event_monitor.sh factory-events <factory_address>
./run_event_monitor.sh position-events <position_manager_address>
```

### Custom Operations
```bash
# Custom swap amounts
./run_user_operation.sh swap 10         # Swap 10 ETH
./run_user_operation.sh swap-reverse 500 # Swap 500 PQUSD

# Custom liquidity amounts
./run_liquidity_management.sh increase 50 500   # 50 ETH, 500 tokens
./run_liquidity_management.sh increase 200 2000 # 200 ETH, 2000 tokens
```

## 📚 More Information

- [Detailed Deployment Guide](STEP_BY_STEP_DEPLOYMENT.md)
- [Script Usage Instructions](SCRIPT_USAGE.md)
- [User Operation Guide](USER_OPERATION_USAGE.md)
- [Original Project Method](ORIGINAL_DEPLOYMENT_GUIDE.md)

---

*This quick start guide helps you complete Uniswap V3 deployment in minutes with advanced features!*