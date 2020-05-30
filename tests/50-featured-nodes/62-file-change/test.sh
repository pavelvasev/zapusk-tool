#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

test -d _state && rm -r _state

../../../zapusk apply55 --zdb cep1.zdb >result.txt 2>&1

test -f _state/alfa-1

../../../zapusk apply55 --zdb cep1.zdb --a "k=42" >result2.txt 2>&1

test ! -f _state/alfa-1
test -f _state/alfa-42

echo test ok