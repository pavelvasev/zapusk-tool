#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk apply --zdb cep1.zdb >result.txt 2>&1 --debug

cat result.txt | grep "das value kukareku 55 ok" -q -x


cat result.txt | grep "das value 777 fin" -q -x

echo test ok