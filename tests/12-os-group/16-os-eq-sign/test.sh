#!/bin/bash -ex

set -e

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk hi5 --zdb cep1.zdb > result.txt 2>&1 --debug
cat result.txt | grep "a=1 b=2" -q -x
echo $?

echo test ok
