# Uniswap V3 Foundry Deployment Project

This is a complete project for deploying Uniswap V3 using Foundry. The project includes all necessary contract deployment scripts and tools, supporting WETH and PQUSD tokens with comprehensive liquidity management and monitoring capabilities.

## 🚀 Quick Start

### 1. Clone Project
```bash
git clone <your-repo-url>
cd uniswapV3_foundry_deployment
```

### 2. Install Dependencies
```bash
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

### 4. Deploy WETH and PQUSD
```bash
# Deploy token contracts
./deploy_weth_pqusd.sh
```

### 5. Check Contract Configuration
```bash
# Check WETH and PQUSD contracts
./check_weth_pqusd.sh
```

### 6. Deploy Uniswap V3
```bash
# Start Anvil node
anvil

# Run deployment in another terminal
./deploy_step_by_step.sh
```

### 7. Deploy QuoterV2
```bash
# Deploy QuoterV2 contract
./run_deploy_quoterV2.sh deploy

# Verify deployment
./run_deploy_quoterV2.sh verify

# Test functionality
./run_deploy_quoterV2.sh test
```

## 📁 Project Structure

```
uniswapV3_foundry_deployment/
├── script/
│   ├── deployQuoterV2.s.sol      # QuoterV2 deployment script
│   ├── liquidityManagement.s.sol  # Liquidity management script
│   ├── useOperation.s.sol         # User operation script
│   └── wethDeposit.s.sol         # WETH deposit script
├── src/
│   ├── WETH.sol                  # WETH contract
│   ├── PQUSD.sol                 # PQUSD token contract
│   ├── UniswapV3FactoryFoundry.sol # Factory contract wrapper
│   ├── SwapRouterFoundry.sol     # Router contract wrapper
│   ├── NonfungiblePositionManagerFoundry.sol # Position manager wrapper
│   ├── NonfungibleTokenPositionDescriptorFoundry.sol # Descriptor wrapper
│   └── NFTDescriptor.sol         # NFT descriptor contract
├── lib/                          # Dependencies
├── deploy_weth_pqusd.sh         # WETH and PQUSD deployment script
├── check_weth_pqusd.sh          # Contract configuration check script
├── deploy_step_by_step.sh       # Complete deployment script
├── run_deploy_quoterV2.sh       # QuoterV2 deployment script
├── run_liquidity_management.sh   # Liquidity management script
├── run_user_operation.sh         # User operation script
├── run_weth_deposit.sh          # WETH deposit script
├── run_event_monitor.sh          # Event monitoring script
├── run_realtime_monitor.sh       # Real-time event monitoring script
├── QUICK_START.md               # Quick start guide
└── foundry.toml                 # Foundry configuration
```

## 🔧 Deployed Contracts

### Token Contracts
1. **WETH** - Wrapped Ether contract
2. **PQUSD** - PQ USD token contract

### Uniswap V3 Core Contracts
3. **UniswapV3Factory** - Factory contract for creating liquidity pools
4. **SwapRouter** - Swap router for executing token swaps
5. **NonfungibleTokenPositionDescriptor** - NFT position descriptor
6. **NonfungiblePositionManager** - NFT position manager
7. **QuoterV2** - Price quotation contract

## 🌐 Supported Networks

### Local Testing (Anvil)
- **RPC URL**: `http://localhost:8545`
- **Chain ID**: 31337
- **WETH**: Auto-deployed
- **PQUSD**: Auto-deployed

### Base Sepolia Testnet
- **WETH Address**: `0x4200000000000000000000000000000000000006`
- **RPC URL**: `https://sepolia.base.org`
- **Chain ID**: 84532

### Other Networks
Support for other networks can be added by modifying addresses in the `.env` file.

## 📋 Deployment Scripts

### Token Deployment (`deploy_weth_pqusd.sh`)
- Deploy WETH and PQUSD contracts
- Automatically update configuration files
- Generate deployment summary

### Contract Check (`check_weth_pqusd.sh`)
- Verify WETH and PQUSD contracts
- Test basic contract functionality
- Check deployer balance

### Complete Deployment (`deploy_step_by_step.sh`)
- Use Anvil local node
- Automatically check contract configuration
- Step-by-step deployment of all Uniswap V3 contracts

### QuoterV2 Deployment (`run_deploy_quoterV2.sh`)
- Deploy QuoterV2 contract
- Verify deployment status
- Test quotation functionality

### User Operations (`run_user_operation.sh`)
- Token swaps (WETH ↔ PQUSD) with custom amounts
- Add liquidity
- Query balance and pool information
- Support for parameterized operations

### Liquidity Management (`run_liquidity_management.sh`)
- Add liquidity (mint)
- Increase/decrease liquidity with custom amounts
- Collect fees
- Burn positions
- Query balance and liquidity status

### WETH Deposit (`run_weth_deposit.sh`)
- Execute WETH deposit operations
- Support for custom deposit amounts
- Automatic balance checking

## 🧪 Testing Features

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

## 📡 Event Monitoring

The project provides comprehensive event monitoring and decoding functionality:

### Basic Event Monitoring (`run_event_monitor.sh`)
```bash
# Monitor Pool events
./run_event_monitor.sh pool-events [pool_address]

# Monitor Factory events
./run_event_monitor.sh factory-events [factory_address]

# Monitor Position Manager events
./run_event_monitor.sh position-events [position_manager_address]

# Monitor Router events
./run_event_monitor.sh router-events [router_address]

# Monitor QuoterV2 events
./run_event_monitor.sh quoter-events [quoter_address]

# Monitor Token events
./run_event_monitor.sh token-events [token_address]

# Monitor all events
./run_event_monitor.sh all-events

# Decode specific events
./run_event_monitor.sh decode-event [event_signature] [log_data]
```

### Real-time Event Monitoring (`run_realtime_monitor.sh`)
```bash
# Real-time Pool event monitoring
./run_realtime_monitor.sh pool-follow [pool_address]

# Real-time Factory event monitoring
./run_realtime_monitor.sh factory-follow [factory_address]

# Real-time Position Manager event monitoring
./run_realtime_monitor.sh position-follow [position_manager_address]

# Real-time monitoring of all events
./run_realtime_monitor.sh all-follow

# Decode log files
./run_realtime_monitor.sh decode-logs events.log
```

### Supported Event Types
- **Pool Events**: Initialize, Mint, Burn, Swap, Collect, Flash, IncreaseObservationCardinalityNext, SetFeeProtocol, CollectProtocol
- **Factory Events**: PoolCreated, OwnerChanged, FeeAmountEnabled
- **Position Manager Events**: IncreaseLiquidity, DecreaseLiquidity, Collect
- **Router Events**: All swap and routing events
- **QuoterV2 Events**: Quote events
- **ERC20 Events**: Transfer, Approval
- **ERC721 Events**: Transfer, Approval, ApprovalForAll

## 🔍 Verify Deployment

After deployment, you can use the following commands to verify contracts:

```bash
# Check token contracts
cast call <WETH_ADDRESS> "name()" --rpc-url $RPC_URL
cast call <PQUSD_ADDRESS> "name()" --rpc-url $RPC_URL

# Check factory contract
cast call <FACTORY_ADDRESS> "owner()" --rpc-url $RPC_URL

# Check router contract
cast call <ROUTER_ADDRESS> "factory()" --rpc-url $RPC_URL

# Check QuoterV2 contract
cast call <QUOTER_V2_ADDRESS> "factory()" --rpc-url $RPC_URL
```

### Verification Examples

```bash
# Use project RPC URL
export RPC_URL=http://13.54.171.239:8123

# Verify WETH contract
cast call 0x37Ed4cf559Ed4034040F4045045ff3Ff6f3ce5E5 "name()" --rpc-url $RPC_URL
# Output: Wrapped Ether

# Verify PQUSD contract
cast call 0x1984973E205CFBc454C7092d3aD051B54aB6663e "name()" --rpc-url $RPC_URL
# Output: PQ USD

# Verify Factory contract
cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "owner()" --rpc-url $RPC_URL
```

## 🛠️ Requirements

- Latest version of Foundry
- Node.js (optional, for additional tools)
- Sufficient ETH balance to pay gas fees

## 📚 Documentation

- [QUICK_START.md](./QUICK_START.md) - Quick start guide
- [USER_OPERATION_USAGE.md](./USER_OPERATION_USAGE.md) - User operation guide
- [SCRIPT_USAGE.md](./SCRIPT_USAGE.md) - Script usage instructions
- [STEP_BY_STEP_DEPLOYMENT.md](./STEP_BY_STEP_DEPLOYMENT.md) - Detailed deployment guide
- [EVENT_MONITOR_USAGE.md](./EVENT_MONITOR_USAGE.md) - Event monitoring and decoding guide
- [Foundry Documentation](https://book.getfoundry.sh/)
- [Uniswap V3 Documentation](https://docs.uniswap.org/)

## 🆕 Latest Features

### Enhanced Liquidity Management
- **Parameterized Operations**: Support for custom amounts in ETH units
- **Balance Tracking**: Automatic balance change monitoring
- **Flexible Operations**: Mint, increase, decrease, collect, and burn positions

### Advanced User Operations
- **Custom Swap Amounts**: Specify exact amounts for token swaps
- **Reverse Swaps**: Support for PQUSD to WETH swaps
- **Balance Queries**: Comprehensive balance and approval status checking

### Comprehensive Event Monitoring
- **Multi-Contract Support**: Monitor events from all deployed contracts
- **Real-time Monitoring**: Follow events as they happen
- **Event Decoding**: Automatic decoding of complex event data
- **Log Analysis**: Decode and analyze historical event logs

### WETH Management
- **Deposit Operations**: Execute WETH deposits with custom amounts
- **Balance Verification**: Automatic balance checking before operations

## References

https://github.com/MarcusWentz/uniswapV3_foundry_deployment/blob/main/README.md

