#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk apply55 --zdb cep1.zdb >result.txt 2>&1

cat result.txt | grep "btw, command is apply55" -qx

cat _state/alfa | grep "echo I am alfa, beta is 14" -qx
cat _state/alfa | grep "echo btw, command is apply55" -qx

_state/alfa | grep "I am alfa, beta is 14" -qx

echo test ok