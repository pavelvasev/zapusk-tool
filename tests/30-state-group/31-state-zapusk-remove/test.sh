#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

test -d _zapusk.removed && rm -rf _zapusk.removed
test -d _state && rm -rf _state

../../../zapusk deploy --zdb ../cep1.zdb --state_dir _state

test -d _state
echo secretik>_state/secret.txt

../../../zapusk destroy --zdb ../cep1.zdb --state_dir _state

test ! -d _state
test -d _zapusk.removed
find _zapusk.removed -name secret.txt
cat `find _zapusk.removed -name secret.txt`|grep "secretik"

echo ok