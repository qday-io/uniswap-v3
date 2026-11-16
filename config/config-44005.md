# Chain Configuration - Chain ID: 44005

## Network

- **Chain ID**: 44005
- **RPC URL**: https://rpc-test.qday.info
- **Network name**: Unknown Network

## Contract addresses

| Contract | Environment variable | Address | Status |
|---------|---------|------|------|
| WETH | WETH_ADDRESS | 0x915E807e7EC1665889172902781FB851202A54dF | ✅ Deployed |
| PQUSD | PQUSD_ADDRESS | 0x456569838f1d43009A91ebA4263147Afd7233483 | ✅ Deployed |
| Swap Router | SWAP_ROUTER_ADDRESS | 0xF03972436D2F0fbAb481f769ECafE172a803eB10 | ✅ Deployed |
| Position Manager | POSITION_MANAGER_ADDRESS | 0x339a0C6E6582B2674EDf6987099BD7B7c50159c7 | ✅ Deployed |
| Factory | FACTORY_ADDRESS | 0x31ff878190Cf74E37d963F77599abB674d27A787 | ✅ Deployed |
| Quoter V2 | QUOTER_V2_ADDRESS | 0x7d69E50c875Eacc4EE9E12D2C282c20049965FA5 | ✅ Deployed |


- **POOL_INIT_CODE_HASH**: `0xecd39ca8f1e3b909cf2f7c23841c629bdade53b8b821b001988ffc913effbb4f`

## Deployment

- **Deployer address**: 0x4E6559E2DB5f1907365629CCbe8Ab615101a943A
- **Created token ID**: 1

## Deployment scripts

- WETH & PQUSD: `./deploy_weth_pqusd.sh`
- Core contracts: `./deploy_step_by_step.sh`
- Quoter V2: `./run_deploy_quoterV2.sh`

## Verification commands

```bash
# Check environment variables
source .env
echo "WETH_ADDRESS: $WETH_ADDRESS"
echo "PQUSD_ADDRESS: $PQUSD_ADDRESS"
echo "FACTORY_ADDRESS: $FACTORY_ADDRESS"
echo "SWAP_ROUTER_ADDRESS: $SWAP_ROUTER_ADDRESS"
echo "POSITION_MANAGER_ADDRESS: $POSITION_MANAGER_ADDRESS"
echo "QUOTER_V2_ADDRESS: $QUOTER_V2_ADDRESS"

# Verify contract code
cast code $WETH_ADDRESS --rpc-url $RPC_URL
cast code $PQUSD_ADDRESS --rpc-url $RPC_URL
```

---
*Configuration generated at: Mon Nov 16 23:22:40 CST 2026*
*Chain ID: 44005*
