#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

test -d _state && rm -r _state

echo "secret" > cep1.zdb/important-file

../../../zapusk apply55 --zdb cep1.zdb

cat cep1.zdb/important-file

../../../zapusk destroy --zdb cep1.zdb

cat cep1.zdb/important-file | grep "secret"

echo test ok
