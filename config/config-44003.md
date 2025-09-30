# 链配置信息 - Chain ID: 44003

## 网络信息
- **链ID**: 44003
- **RPC URL**: https://rpc-0.qday.info
- **网络名称**: Unknown Network

## 合约地址

| 合约名称 | 环境变量 | 地址 | 状态 |
|---------|---------|------|------|
| WETH | WETH_ADDRESS | 0x699F540c974430781C618fB8033A1e3FF75C43D2 | ✅ 已部署 |
| PQUSD | PQUSD_ADDRESS | 0x920D87c134CDba694535706F5D28e05b13C2B272 | ✅ 已部署 |
| Swap Router | SWAP_ROUTER_ADDRESS | 0x0198D6Bc2bd3f8D24C7A502E0d76bf82d3101098 | ✅ 已部署 |
| Position Manager | POSITION_MANAGER_ADDRESS | 0xE9104868e9a84bA3aB122D597fa34fb52AFd0395 | ✅ 已部署 |
| Factory | FACTORY_ADDRESS | 0x5e977bC5f24cF3Cd94B92fdAc63a0306d3792f9E | ✅ 已部署 |
| Quoter V2 | QUOTER_V2_ADDRESS | 0xD560fA95B55Cda7c5bC4a3A0d339f55204AEb571 | ✅ 已部署 |

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
*配置文件生成时间: Tue Sep 30 22:54:33 CST 2025*
*链ID: 44003*
