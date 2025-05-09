# Aztec Validator Node Manager

A one-click script to install, configure, and manage your Aztec Alpha-Testnet validator node.  
**By TG - @Brock0021**

## 🔧 📋 Prerequisites
- OS: Ubuntu-based system (tested on 20.04+)
- Machine Specs: 8‑Core CPU, 16 GiB RAM, 1 TB NVMe SSD (MINIMUM 250GB)
- Network: ≥25 Mbps up/down bandwidth (typical consumer desktop or laptop is sufficient)
- Server Requirements: Ensure these specs are met; if not, reach out for assistance.
- RPC Endpoint: For best performance, use a paid Ankr RPC. For a free alternative, try DRPC: https://drpc.org?ref=1e9da0

## 🔧 Features

- Full node setup with Docker
- Validator registration
- Apprentice role fetch
- Auto-restart and RPC change options
- Safe environment variable management (`.env`)


📜 Menu Options
---------------

1.  Setup Node Validator  
2.  Get Role Apprentice  
3.  Register Validator  
4.  Stop/Restart Node  
5.  Change RPC  
6.  Clean or Reinstall  

👨‍💻 Author
------------

**TG - Brock0021**  
Maintained by [tnetone1](https://github.com/tnetone1)

* * *

This script is for educational/testnet use. No warranty provided.


## 🚀 Quick Start

Run the following commands **one by one** in your terminal:

```bash
sudo apt install screen

screen -S aztec

git clone https://github.com/tnetone1/aztec-validator-node.git

cd aztec-validator-node

chmod +x manage_node.sh

./manage_node.sh
```

**While Running Script** :-

**Sepolia RPC**: Add the Sepolia RPC link in the relevant section for the Sepolia network.

**Beacon**: Similarly, add the Beacon Sepolia link where it is required.

**Public**: In the Public section, input the address of the wallet you want to use in MetaMask (the burner wallet address). Ensure that the address is correct and in the right format.

**Private Key**: Copy your MetaMask private key and paste it where necessary. Don't forget to add 0x at the beginning of the private key.

For example, if your private key is: ane7anegbnaje88ame, make sure it appears as 0xane7anegbnaje88ame.

**IMPORTENT**: After copying the private key, paste it into the appropriate section on your VPS. You only need to click once, and the private key will stay hidden for security.
