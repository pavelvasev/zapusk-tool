#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk destroy --zdb ../cep1.zdb >result.txt 2>&1 --state_dir _state

if cat result.txt | grep "subitem destroyed" -qx; then
  echo "nobody should be destroyed - due to no state for them"
  exit 1
fi

if cat result.txt | grep "subitem2 destroyed" -qx; then
  echo "nobody should be destroyed - due to no state for them"
  exit 1
fi

echo test ok