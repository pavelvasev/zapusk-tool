#!/bin/bash -ex

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../../zapusk test1 --zdb cep1.zdb >result.txt 2>&1 --debug

cat result.txt | grep "kukareku value 55 with more space" -q -x

# we use another encoding for now, https://ruby-doc.org/stdlib-1.9.3/libdoc/shellwords/rdoc/Shellwords.html#method-c-shellescape
#cat ~state/beta/params.txt | grep 'beta55="kukareku value 55 with more space"' -q -x

echo test ok