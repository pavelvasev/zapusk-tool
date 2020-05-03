#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../zapusk apply55 --zdb cep1.zdb >result.txt 2>&1 --debug
# if following passes, nxt.ini is generated ok

cat result.txt | grep "type=zuka" -qx
cat result.txt | grep "name=zuka2" -qx

echo test ok