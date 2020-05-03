#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk deploy --zdb ../cep1.zdb >result.txt 2>&1 --state_dir _state

if test -d _state/subitem2; then
  echo "subitem2 state should not be created!"
  exit 1
fi

echo test ok