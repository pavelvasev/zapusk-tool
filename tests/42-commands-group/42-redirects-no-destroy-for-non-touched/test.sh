#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk deploy --zdb ../cep1.zdb >result.txt 2>&1 --state_dir _state
../../../zapusk destroy --zdb ../cep1.zdb >result2.txt 2>&1 --state_dir _state

cat result2.txt|grep "subitem destroyed" -q

if cat result2.txt|grep "subitem2 destroyed" -qx; then
  echo "subitem2 destroy should not be called"
  exit 1
fi

echo test ok