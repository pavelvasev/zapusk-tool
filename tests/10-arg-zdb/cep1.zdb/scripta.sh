#!/bin/bash

echo I am scripta-sh, cmd=$1
echo ls is
ls -la *
echo params are
cat params.txt

. params.sh

echo "vars: a=$a, b=$b, c=$c"