#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../zapusk hello --zdb cep1.zdb >result.txt 2>&1

cat result.txt | grep "alfa a=5 b=7!"
cat result.txt | grep "alfa a=555 b=777!"

echo test ok