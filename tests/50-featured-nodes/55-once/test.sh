#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk destroy --zdb cep1.zdb >result0.txt 2>&1 --debug

../../../zapusk test1 --zdb cep1.zdb >result1.txt 2>&1 --debug
../../../zapusk test1 --zdb cep1.zdb >result2.txt 2>&1 --debug
../../../zapusk system-update --zdb cep1.zdb >result3.txt 2>&1 --debug
../../../zapusk system-update --zdb cep1.zdb >result4.txt 2>&1 --debug

cat result1.txt | grep "called test1" -qx
cat result2.txt | grep "called test1" -qx
cat result3.txt | grep "called system-update" -qx

if cat result4.txt | grep "called system-update" -qx; then
  echo "called system-update should not be here"
  exit 1
fi

echo test ok
