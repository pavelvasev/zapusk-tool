#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk deploy --zdb ../cep2.zdb --state_dir _state
../../../zapusk destroy --zdb ../cep2.zdb --state_dir _state >result.txt 2>&1 --debug

if test "$(cat result.txt | grep 'teta destroy called' -x -c)" = "2"; then
  echo okkkey
else
  echo "teta should be destroyed exactly 2 times"
  exit 1
fi

echo ok