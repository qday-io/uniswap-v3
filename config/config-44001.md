# 链配置信息 - Chain ID: 44001

## 网络信息
- **链ID**: 44001
- **RPC URL**: https://rpc.qday.io
- **网络名称**: Unknown Network

## 合约地址

| 合约名称 | 环境变量 | 地址 | 状态 |
|---------|---------|------|------|
| WETH | WETH_ADDRESS | 0xEF253e9FC2d063869FD5B3C0E1c326aB7E030660 | ✅ 已部署 |
| PQUSD | PQUSD_ADDRESS | 0x668FaAFd6b363d6cED62491BfCBE2A39da3D14cB | ✅ 已部署 |
| Swap Router | SWAP_ROUTER_ADDRESS | 0xdbd7E0A062682184b85a728de53A9902909f4De8 | ✅ 已部署 |
| Position Manager | POSITION_MANAGER_ADDRESS | 0x6D5db9cf683F3c5f2761862fdfe6A1F5de071aC2 | ✅ 已部署 |
| Factory | FACTORY_ADDRESS | 0x03C3Cd5b113a3Aa400AC2F76cDedeE439EA36A71 | ✅ 已部署 |
| Quoter V2 | QUOTER_V2_ADDRESS | 0xC7Af29B126889D96239EdbAbfeb26D46DF5A6CFa | ✅ 已部署 |

## 部署信息
- **部署者地址**: 0xefF571C19b5e5789c840f5f79909eA8cC30EF0b7
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
*配置文件生成时间: Mon Nov 24 17:02:12 CST 2025*
*链ID: 44001*
