#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk predeploy --zdb ../cep1.zdb >result.txt 2>&1 --state_dir _state
../../../zapusk deploy --zdb ../cep1.zdb >result2.txt 2>&1 --state_dir _state
../../../zapusk system-update --zdb ../cep1.zdb >result3.txt 2>&1 --state_dir _state

cat result.txt | grep C1 -q
cat result2.txt | grep C1 -q
cat result2.txt | grep C2 -q
cat result3.txt | grep APPLY1 -q

echo test ok