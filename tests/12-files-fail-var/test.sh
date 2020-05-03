#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

(../../zapusk deploy --zdb cep1.zdb  >result.txt 2>&1) || echo "if not found c var - it is ok"

cat result.txt | grep "value for name=c not found!"

echo test ok
