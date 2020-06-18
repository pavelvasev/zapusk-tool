#!/bin/bash -e

Q=$(dirname "$(readlink -f "$0")")
pushd "$Q"

################# funcs
echo_link () {
  echo "linking '$1' → '$2'"
  ln -sf "$1" "$2"
}

sudo_echo_link () {
  echo "linking '$1' → '$2'"
  sudo ln -sf "$1" "$2"
}

################ download and setup

echo "===== checking local ruby"

arch=$(uname -m)
if test "$arch"  == "x86_64"; then
  if test ! -d ruby.local
  then
    curl -L -O --fail https://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-20141215-2.1.5-linux-x86_64.tar.gz
    mkdir ruby.local && tar -xzf traveling-ruby-20141215-2.1.5-linux-x86_64.tar.gz -C ruby.local && rm traveling-ruby-20141215-2.1.5-linux-x86_64.tar.gz
    #echo making file link for local zapusk command
    echo_link src.v1/zapusk-ruby-local zapusk
  fi
else
  if ruby -v; then
    echo "Your arch=$arch, detected ruby in system, it will be used run zapusk."
  else
    echo "!!!!!!!!!!!!!!!!!!!!!!! WARNING! Your arch=$arch, please install ruby to run zapusk. !!!!!!!!!!!!!!!!"
  fi
  echo_link src.v1/zapusk-ruby-system zapusk
fi

################## setup
# deploys links into system

echo "===== making file links to zapusk for host system"

TD=/usr/local/bin

sudo_echo_link $(readlink -f zapusk) "$TD/zapusk"

################## extra link for zapusk-lact-libs
# this is placed here in order to not call any extra setup scripts for libs
# (probably this should change in future)
if test -f lib/zapusk-lact-libs/chroota.zdb/chroot-tool/chroot-tool.sh; then
  sudo_echo_link $(readlink -f lib/zapusk-lact-libs/chroota.zdb/chroot-tool/chroot-tool.sh) "$TD/chroot-tool.sh"
fi

echo "===== result"
echo "ALL DONE OK!"