#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk huhu --zdb cep0.zdb --debug

test -d cep0.zdb/_state22

echo test ok