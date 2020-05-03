#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk deploy --zdb ../cep1.zdb --state_dir _state
../../../zapusk destroy --zdb ../cep1.zdb --state_dir _state

test ! -d _state

echo ok