#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk system-update --zdb cep1.zdb >result.txt 2>&1 --debug

cat result.txt | grep "called a" -qx
cat result.txt | grep "called b" -qx
cat result.txt | grep "called d" -qx
cat result.txt | grep "called e" -qx

if cat result.txt | grep "called c" -qx; then
  echo "called c should not be here"
  exit 1
fi

echo test ok