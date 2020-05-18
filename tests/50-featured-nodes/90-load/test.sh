#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

ZAPUSK_DEBUG=--debug ../../../zapusk apply --zdb cep1.zdb >result0.txt 2>&1
ZAPUSK_DEBUG=--debug ../../../zapusk destroy --zdb cep1.zdb >result1.txt 2>&1

cat result0.txt | grep "A1 applied cep1-item1" -qx
cat result0.txt | grep "A3 applied cep1-item1-more" -qx
cat result0.txt | grep "A2 applied cep1-item1" -qx

cat result1.txt | grep "A1 destroyed cep1-item1" -qx
cat result1.txt | grep "A3 destroyed cep1-item1-more" -qx
cat result1.txt | grep "A2 destroyed cep1-item1" -qx

echo test ok