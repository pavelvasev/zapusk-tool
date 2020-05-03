#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk hi5 --zdb cep1.zdb >result.txt 2>&1
cat result.txt | grep "I am bash script, mihi"

echo test ok