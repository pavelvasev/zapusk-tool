#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk apply --zdb cep0.zdb >result.txt 2>&1 --state_dir _state

if cat result.txt | grep "APPLIED" -qx; then
 echo "APPLIED SHOULD NOT BE CALLED"
 exit 1
fi

echo test ok