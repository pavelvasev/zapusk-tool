#/bin/bash

Q=$(dirname "$(readlink -f "$0")")

$Q/../test.sh $(basename $Q)