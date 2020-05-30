#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk apply55 --zdb cep1.zdb >result.txt 2>&1

if cat result.txt | grep "btw, command is apply55" -qx; then
  echo "this string should not be there!"
  exit 1
fi

cat result.txt | grep "WARNING: following steps never will be performed"

echo test ok