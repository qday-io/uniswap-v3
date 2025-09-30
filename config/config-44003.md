# 链配置信息 - Chain ID: 44003

## 网络信息
- **链ID**: 44003
- **RPC URL**: https://rpc-0.qday.info
- **网络名称**: Unknown Network

## 合约地址

| 合约名称 | 环境变量 | 地址 | 状态 |
|---------|---------|------|------|
| WETH | WETH_ADDRESS | 0xeA6b7df95cF38E0e707b4E4da76E7bD18A7Dd133 | ✅ 已部署 |
| PQUSD | PQUSD_ADDRESS | 0x339a0C6E6582B2674EDf6987099BD7B7c50159c7 | ✅ 已部署 |
| Swap Router | SWAP_ROUTER_ADDRESS | 0x6f46006d37c082a6994840Cd293384F0b81C0d48 | ✅ 已部署 |
| Position Manager | POSITION_MANAGER_ADDRESS | 0xEC98c994da30c7907566Bbf98eFF14EA5375C2C3 | ✅ 已部署 |
| Factory | FACTORY_ADDRESS | 0x3365a31694Ec54AA83C62F3A77e12f8147f9360E | ✅ 已部署 |
| Quoter V2 | QUOTER_V2_ADDRESS | 0x749c3D8d63ce3c2a126084b79d96Ce4C1af67f7C | ✅ 已部署 |

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
*配置文件生成时间: Tue Sep 30 22:39:31 CST 2025*
*链ID: 44003*
