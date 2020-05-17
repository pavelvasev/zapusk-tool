#!/bin/bash -e

Q=$(dirname "$(readlink -f "$0")")
pushd "$Q"

################ download

echo checking local ruby

if test ! -d ruby.local
then
  curl -L -O --fail https://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20141215-2.1.5-linux-x86_64.tar.gz
  mkdir ruby.local && tar -xzf traveling-ruby-20141215-2.1.5-linux-x86_64.tar.gz -C ruby.local && rm traveling-ruby-20141215-2.1.5-linux-x86_64.tar.gz
fi

################ setup local zapusk link

echo making file link for local zapusk command

echo_link () {
  echo "linking '$1' → '$2'"
  ln -sfr "$1" "$2"
}

echo_link src.v1/zapusk-ruby-local zapusk

################## setup
# deploys links into system

echo making file links to zapusk for host system

TD=/usr/local/bin

echo_link zapusk "$TD/zapusk"

################## extra link for zapusk-lact-libs
# this is placed here in order to not call any extra setup scripts for libs
# (probably this should change in future)

echo_link lib/zapusk-lact-libs/chroota.zdb/chroot-tool/chroot-tool.sh "$TD/chroot-tool.sh"

echo "ALL DONE OK!"