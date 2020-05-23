#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../zapusk apply --zdb cep1.zdb >result.txt 2>&1

cat result.txt | grep "WARNING: check value for {}"

echo test ok