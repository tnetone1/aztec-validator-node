# Aztec Validator Node Manager

Script to install, configure, and manage your Aztec Alpha-Testnet validator node.  
**By TG - @Brock0021**

## 🔧 📋 Prerequisites
- OS: Ubuntu-based system (tested on 20.04+)
- Machine Specs: 8‑Core CPU, 16 GiB RAM, 1 TB NVMe SSD (MINIMUM 250GB)
- Network: ≥25 Mbps up/down bandwidth (typical consumer desktop or laptop is sufficient)
- Server Requirements: Ensure these specs are met; if not, reach out for assistance.
- RPC Endpoint: For best performance, use a paid Ankr RPC. For a free alternative, try DRPC: https://drpc.org?ref=1e9da0
- For Eth Sepolia - https://nodereal.io/invite/167cf1bf-4e03-45ab-a9e8-830e11e2a1ef
- For Beacon Sepolia - https://access.rockx.com?r=8utAnWHoNuu

## 🔧 Features

- Full node setup with Docker
- Validator registration
- Apprentice role fetch
- Auto-restart and RPC change options
- Safe environment variable management (`.env`)


📜 Menu Options
---------------

1) Setup Node Validator
2) Get Role Apprentice
3) Register Validator
4) Stop Node
5) Restart Node
6) Change RPC
7) Delete Node Data
8) Full Clean
9) Reinstall Node
x) Exit

👨‍💻 Author
------------

**TG - Brock0021**  
Maintained by [tnetone1](https://github.com/tnetone1)

* * *

This script is for educational/testnet use. No warranty provided.


## 🚀 Quick Start

Run the following commands **one by one** in your terminal:

**First you need docker installed on your system If Not See FAQ( FAQ IS IN END OF THIS GUIDE)**

**Also If Sudo Not Installed See FAQ**
**ALL ERRORS SOLUTION IN FAQ  AND IF NOT MENTION YOUR ERROR IN FAQ YOU CAN INBOX ME https://t.me/Brock0021**

**firstly login as root** 
```sudo -i``` or  ``` su - ```

```
sudo apt update -y
sudo apt upgrade -y
```
```
sudo apt-get update
sudo apt-get install curl

sudo apt-get update
sudo apt-get install nano
```
```
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt update && sudo apt install -y nodejs
```
```
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev screen ufw -y
```
```
sudo apt install ufw

sudo ufw allow 22
sudo ufw allow ssh
sudo ufw enable
```
```
sudo ufw allow 40400
sudo ufw allow 8080
```

- **Create a Screen Session**
```bash
sudo apt install screen

screen -S aztec
```
- **Start Your Sequencer 🍥**
```
sudo apt update && sudo apt install git -y

git clone https://github.com/tnetone1/aztec-validator-node.git

cd aztec-validator-node

chmod +x custom_port.sh

./custom_port.sh

```

- **For Detached and Attached From the Screen :-**

- For detached from screen session - ```ctrl``` , ```a``` + ```d```

- For Attach -
```
screen -r aztec
```
**While Running Script** :-


**Sepolia RPC**: Add the Sepolia RPC link in the relevant section for the Sepolia network.
For Eth Sepolia - https://nodereal.io/invite/167cf1bf-4e03-45ab-a9e8-830e11e2a1ef

**Beacon**: Similarly, add the Beacon Sepolia link where it is required.
For Beacon Sepolia - https://access.rockx.com?r=8utAnWHoNuu

**Public**: In the Public section, input the address of the wallet you want to use in MetaMask (the burner wallet address). Ensure that the address is correct and in the right format.

**Private Key**: Copy your MetaMask private key and paste it where necessary. Don't forget to add 0x at the beginning of the private key.

For example, if your private key is: ane7anegbnaje88ame, make sure it appears as 0xane7anegbnaje88ame.

**IMPORTENT**: After copying the private key, paste it into the appropriate section on your VPS. You only need to click once, and the private key will stay hidden for security.

**IMP** Required Sepolia Faucet Eth Search From google or youtube etc...



👨‍💻 FAQ
------------

- **Install Docker & Docker Compose**

```
sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
```
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
```
sudo apt update && sudo apt install -y docker-ce && sudo systemctl enable --now docker
```
```
sudo usermod -aG docker $USER && newgrp docker
```
```
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
```
- Verify installation
```
docker --version && docker-compose --version
```

- **if this permission issue**

permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.49/containers/json?filters=%7B%22ancestor%22%3A%7B%22aztecprotocol%2Faztec%22%3Atrue%7D%7D": dial unix /var/run/docker.sock: connect: permission denied

run any one Below Command (Root/Non-root)

**if root user**
```
newgrp docker
```
```
docker ps
```

**if Normal user**
```
sudo newgrp docker
```
```
docker ps
```

- **IF Docker Start Issue**
```
sudo systemctl start docker

sudo systemctl enable docker

sudo systemctl status docker

```
- **Sudo Not Installed Then Install Now**
```
apt update && apt install sudo -y
```


- ** if forgot root password you can ask chatgpt or try this command
``` passwd ``` oR ``` sudo passwd ```



- **🔍 Aztec Validator Health Check Script**
Monitor your Aztec validator status including:

✅ Geth (execution layer) sync

✅ Beacon (consensus layer) sync

✅ Aztec L2 proven block availability

📦 Installation
```
curl -o aztec_health_check.sh https://raw.githubusercontent.com/tnetone1/aztec-validator-node/main/aztec_health_check.sh
chmod +x aztec_health_check.sh
```
