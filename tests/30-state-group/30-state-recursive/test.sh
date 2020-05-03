#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk huhu --zdb ../cep1.zdb --state_dir _state

test -d _state
test -d _state/alfa
test -d _state/alfa/teta
test -d _state/alfoid
test -d _state/alfa/teta
test -d _state/beta

echo test ok
