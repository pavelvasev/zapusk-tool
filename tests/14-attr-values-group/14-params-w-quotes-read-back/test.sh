#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk test1 --zdb cep1.zdb >result.txt 2>&1 --debug

cat result.txt | grep "kukareku value 55 with more space" -q -x

pushd _state/beta
../../../../../zapusk test1 >../../result2.txt --debug
popd

cat result2.txt | grep "kukareku value 55 with more space" -q -x

echo test ok