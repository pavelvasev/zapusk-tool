#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk apply >result.txt 2>&1

cat result.txt | grep "Making things of block 1, gn=10-test-1-block-1-item1" -q

cat result.txt | grep "Making things of block 1, gn=10-test-1-block-2, q=5" -q

echo test ok