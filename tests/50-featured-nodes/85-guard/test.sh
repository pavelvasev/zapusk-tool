#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

ZAPUSK_DEBUG=--debug ../../../zapusk apply --zdb cep1.zdb >result0.txt 2>&1
ZAPUSK_DEBUG=--debug ../../../zapusk destroy --zdb cep1.zdb >result1.txt 2>&1

cat result1.txt | grep "A1 destroyed cep1-item2" -qx

if cat result1.txt | grep "A1 destroyed cep1-item1" -qx; then
  echo "Subtype1 should not be destroyed!"
  exit 1
fi

echo test ok