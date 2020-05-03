#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../zapusk hi --zdb cep1.zdb --debug

cat cep1.zdb/_state/params.txt | grep a=1 -x
cat cep1.zdb/_state/params.txt | grep b=2 -x
cat cep1.zdb/_state/params.txt | grep c=3 -x

echo test ok