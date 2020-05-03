#!/bin/bash -e

source params.sh

echo "=== arg_files=$arg_files"

for i in $arg_files
do
echo ===== $i is
cat $i
echo =====
echo "A:$(sed -n 's/type=//p' $i) B:$(sed -n 's/type_dir=//p' $i)"
done
