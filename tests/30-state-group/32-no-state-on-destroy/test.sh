#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

test -d _state && rm -rf _state

../../../zapusk destroy --zdb ../cep1.zdb --state_dir _state

if test -d _state; then
  echo "Destroy should not create state dir!"
  exit 1
fi

echo ok