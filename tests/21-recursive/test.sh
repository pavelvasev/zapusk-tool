#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../zapusk run33 --zdb cep1.zdb > result.txt 2>&1 --debug

echo checking 1
cat result.txt | grep "run33 alfa5" -q
echo checking 2
cat result.txt | grep "run33 alfoid5" -q

echo test ok