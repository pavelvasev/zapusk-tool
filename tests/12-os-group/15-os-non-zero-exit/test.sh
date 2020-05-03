#!/bin/bash -e

Q=$(dirname "$(readlink -f "$0")")

cd $Q

if ../../../zapusk test15 --zdb cep1.zdb; then
  echo "command runned ok = that is fail"
  exit 1
else
  echo "command failed -- that's what we need, ok!"
  echo "Test ok!"
fi
