# 合约ABI文件索引

本目录包含所有部署合约的ABI文件，用于前端集成和合约交互。

## ABI文件列表

| 合约名称 | 文件名 | 环境变量 | 描述 |
|---------|--------|---------|------|
| WETH | weth.json | WETH_ADDRESS | Wrapped Ether 代币合约 |
| PQUSD | pqusd.json | PQUSD_ADDRESS | PQUSD 代币合约 |
| Swap Router | swap_router.json | SWAP_ROUTER_ADDRESS | Uniswap V3 交换路由器 |
| Position Manager | position_manager.json | POSITION_MANAGER_ADDRESS | NFT 位置管理器 |
| Factory | factory.json | FACTORY_ADDRESS | Uniswap V3 工厂合约 |
| Quoter V2 | quoter_v2.json | QUOTER_V2_ADDRESS | 价格查询合约 V2 |

## 使用方法

### JavaScript/TypeScript
```javascript
import wethABI from './config/weth.json';
import pqusdABI from './config/pqusd.json';
import swapRouterABI from './config/swap_router.json';

// 使用ABI创建合约实例
const wethContract = new ethers.Contract(wethAddress, wethABI, provider);
const pqusdContract = new ethers.Contract(pqusdAddress, pqusdABI, provider);
const swapRouterContract = new ethers.Contract(swapRouterAddress, swapRouterABI, provider);
```

### Python
```python
import json
from web3 import Web3

# 加载ABI
with open('config/weth.json', 'r') as f:
    weth_abi = json.load(f)

with open('config/pqusd.json', 'r') as f:
    pqusd_abi = json.load(f)

# 创建合约实例
weth_contract = web3.eth.contract(address=weth_address, abi=weth_abi)
pqusd_contract = web3.eth.contract(address=pqusd_address, abi=pqusd_abi)
```

## 更新ABI文件

运行以下命令更新所有ABI文件：
```bash
./collect_config.sh
```

---
*最后更新: Mon Nov 24 17:10:43 CST 2025*
