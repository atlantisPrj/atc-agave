#!/bin/bash
#
#

sudo sysctl -w net.core.rmem_default=134217728
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_default=134217728
sudo sysctl -w net.core.wmem_max=134217728
sudo sysctl -w vm.max_map_count=1000000
sudo sysctl -w fs.nr_open=1000000

#ulimit -n 1000000

maxOpenFds=1000000
ulimit -n $maxOpenFds

if [[ $(ulimit -n) -lt $maxOpenFds ]]; then
  ulimit -n $maxOpenFds 2>/dev/null || {
    echo "Error: nofiles too small: $(ulimit -n). Failed to run \"ulimit -n $maxOpenFds\"";
    if [[ $(uname) = Darwin ]]; then
      echo "Try running |sudo launchctl limit maxfiles 65536 200000| first"
    fi
  }
fi

sudo ntpdate -u pool.ntp.org   #同步时间

#start master node
nohup ./run.sh > ./start.log 2>&1 &

DATA_DIR=./data
validator=$DATA_DIR/run/validator-identity.json

sleep 10


if ps -l | grep "agave-validator" > /dev/null; then
  echo "agave-validator 运行成功"
  solana validator-info publish "Master Validator"  --keypair "$validator"
  echo "主节点发布成功!"
else
  echo "agave-validator 启动失败"
fi
