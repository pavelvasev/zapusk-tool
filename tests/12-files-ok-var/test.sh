#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../zapusk test1 --zdb cep1.zdb >result.txt 2>&1

cat result.txt | grep "test1 kukareku-value-55"

echo test ok