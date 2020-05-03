#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk system-update --zdb cep0.zdb >result.txt 2>&1 --debug

cat result.txt | grep "APPLIED" -qx

echo test ok