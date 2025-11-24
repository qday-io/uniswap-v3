# 链配置信息 - Chain ID: 44003

## 网络信息
- **链ID**: 44003
- **RPC URL**: https://rpc.qday.info
- **网络名称**: Unknown Network

## 合约地址

| 合约名称 | 环境变量 | 地址 | 状态 |
|---------|---------|------|------|
| WETH | WETH_ADDRESS | 0x31ff878190Cf74E37d963F77599abB674d27A787 | ✅ 已部署 |
| PQUSD | PQUSD_ADDRESS | 未设置 | ❌ 未部署 |
| Swap Router | SWAP_ROUTER_ADDRESS | 0x5deCEf80363C3494F38Ce7A694fe86833B9f674e | ✅ 已部署 |
| Position Manager | POSITION_MANAGER_ADDRESS | 0x8C81594a06eF668Be8C043ccf2b68652c66A1d29 | ✅ 已部署 |
| Factory | FACTORY_ADDRESS | 0x85146103E26142253622757Cb2b1604f76fAB2B2 | ✅ 已部署 |
| Quoter V2 | QUOTER_V2_ADDRESS | 0x14e5eF0F7d3F46Dd850B199984C5F8D596D2465c | ✅ 已部署 |

## 部署信息
- **部署者地址**: 0x4E6559E2DB5f1907365629CCbe8Ab615101a943A
- **创建代币ID**: 1

## 部署脚本
- WETH & PQUSD: `./deploy_weth_pqusd.sh`
- 核心合约: `./deploy_step_by_step.sh`
- Quoter V2: `./run_deploy_quoterV2.sh`

## 验证命令
```bash
# 检查环境变量
source .env
echo "WETH_ADDRESS: $WETH_ADDRESS"
echo "PQUSD_ADDRESS: $PQUSD_ADDRESS"
echo "FACTORY_ADDRESS: $FACTORY_ADDRESS"
echo "SWAP_ROUTER_ADDRESS: $SWAP_ROUTER_ADDRESS"
echo "POSITION_MANAGER_ADDRESS: $POSITION_MANAGER_ADDRESS"
echo "QUOTER_V2_ADDRESS: $QUOTER_V2_ADDRESS"

# 验证合约代码
cast code $WETH_ADDRESS --rpc-url $RPC_URL
cast code $PQUSD_ADDRESS --rpc-url $RPC_URL
```

---
*配置文件生成时间: Mon Nov 24 17:10:43 CST 2025*
*链ID: 44003*
