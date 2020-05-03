#!/bin/bash -e

Q=$(dirname "$(readlink -f "$0")")

cd $Q

ZAPUSK_DEBUG=--debug ../../../zapusk apply --zdb cep1.zdb >result.txt 2>&1 --a "*/p1=155"

cat result.txt | grep "p1=155 value" -qx

echo test ok