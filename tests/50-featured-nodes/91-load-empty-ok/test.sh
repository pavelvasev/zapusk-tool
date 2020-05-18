#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk apply --zdb cep1.zdb >result0.txt 2>&1

# not failed => ok

echo test ok