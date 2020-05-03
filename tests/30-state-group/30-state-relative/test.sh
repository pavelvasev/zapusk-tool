#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk huhu --zdb cep0.zdb

test -d _state

echo test ok