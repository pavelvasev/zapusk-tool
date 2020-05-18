#/bin/bash

Q=$(dirname "$(readlink -f "$0")")
cd $Q

TGT="$1"
K="$1"
MSG="FINISHED OK: $K"

if test -z "$TGT"; then
  TGT=.
  K=$(basename "$Q")
  MSG="ALL TESTS FINISHED OK"
fi

# this dostn stop on fail
# find . -type f -name "test.rb" -exec sh -c 'echo ================== {}; ruby {}' \;

shopt -s globstar
set -e
for x in $TGT/*/test.sh; do
  echo "================== $x"
  "$x"
done

#popd

echo "$MSG"
