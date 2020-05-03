#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk hi5 --zdb cep1.zdb >result.txt 2>&1
cat result.txt | grep "I am bash script, mihoy. My arg1 is 17 and arg2 is 56. Thats it."

echo test ok