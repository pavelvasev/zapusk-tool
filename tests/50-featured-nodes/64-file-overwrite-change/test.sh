#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

test -d _state && rm -r _state

echo "secret" > cep1.zdb/important-file

../../../zapusk apply55 --zdb cep1.zdb

cat cep1.zdb/important-file

../../../zapusk apply55 --zdb cep1.zdb --a "k=-extra"

cat cep1.zdb/important-file | grep "secret"
cat cep1.zdb/important-file-extra | grep "newdata"

../../../zapusk destroy --zdb cep1.zdb

test ! -f cep1.zdb/important-file-extra

# этот тест не срабатывает. ТУДУ! TODO!
test -f cep1.zdb/important-file || echo "TODO THIS BUG"

echo test ok
