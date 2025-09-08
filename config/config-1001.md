# 链配置信息 - Chain ID: 1001

## 网络信息
- **链ID**: 1001
- **RPC URL**: http://13.54.171.239:8123
- **网络名称**: Custom Network

## 合约地址

| 合约名称 | 环境变量 | 地址 | 状态 |
|---------|---------|------|------|
| WETH | WETH_ADDRESS | 0x4569CAEF2b72dda4bd73473f3966f65063553444 | ✅ 已部署 |
| PQUSD | PQUSD_ADDRESS | 0xA0E634AEf576d4AC79e9a1Ce59225f89918bC84F | ✅ 已部署 |
| Swap Router | SWAP_ROUTER_ADDRESS | 0xDd3cbeBaEE2e390a34B48e9bF1F93fe8a41453d0 | ✅ 已部署 |
| Position Manager | POSITION_MANAGER_ADDRESS | 0x93DeCf5b619443647c2c72e6239cEc8cEf1B144c | ✅ 已部署 |
| Factory | FACTORY_ADDRESS | 0xc8003f3B174470ce8b0F2557dA411861Ceb19975 | ✅ 已部署 |
| Quoter V2 | QUOTER_V2_ADDRESS | 0x9e8a72899ae7d6E1494d7e4fb3B7077C89e137CB | ✅ 已部署 |

## 部署信息
- **部署者地址**: 0xD47dac7F1916054A7223A2E63C00635a64fa93A7
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
*配置文件生成时间: Mon Sep  8 11:41:16 CST 2025*
*链ID: 1001*
