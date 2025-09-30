# 链配置信息 - Chain ID: 44003

## 网络信息
- **链ID**: 44003
- **RPC URL**: https://rpc-0.qday.info
- **网络名称**: Unknown Network

## 合约地址

| 合约名称 | 环境变量 | 地址 | 状态 |
|---------|---------|------|------|
| WETH | WETH_ADDRESS | 0x1e16f76d65A800812E459a4cc94ce829D3993F00 | ✅ 已部署 |
| PQUSD | PQUSD_ADDRESS | 0x789100cAF4fF90b3a548FAb6C773Ab739D349B2a | ✅ 已部署 |
| Swap Router | SWAP_ROUTER_ADDRESS | 0xB391D4B616aD29A9C31C20aFE75D108a2854B72f | ✅ 已部署 |
| Position Manager | POSITION_MANAGER_ADDRESS | 0x91EfC4b4214A3EA4943CdfD132641a48c21D0F29 | ✅ 已部署 |
| Factory | FACTORY_ADDRESS | 0x0a27E04E4A87dc730d77844a4D2eAd4e0FA62c6b | ✅ 已部署 |
| Quoter V2 | QUOTER_V2_ADDRESS | 0xe79059C8DAc7EbB73A9a3EFbA1B2E6721e61e9ec | ✅ 已部署 |

## 部署信息
- **部署者地址**: 0x932C857b5B2C4206a51FC47AE559829F787aa14c
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
*配置文件生成时间: Wed Oct  1 01:34:16 CST 2025*
*链ID: 44003*
