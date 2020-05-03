#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk test1 --zdb cep1.zdb >result.txt 2>&1 --debug

cat result.txt | grep "kukareku value \"5 5 5\" with more space" -q -x

echo test ok