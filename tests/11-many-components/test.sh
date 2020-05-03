#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../zapusk hello --zdb cep1.zdb  >result.txt 2>&1 --debug

cat result.txt | grep "alfa is running" -x
cat result.txt | grep "beta is running" -x
# cat result.txt | grep "teta is running" -x

echo test ok