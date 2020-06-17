#!/bin/bash -e

source params.sh

if test -z "$arg_files"; then
  exit 0
fi

test ! -z "$cmd"

runbox=xif-arguments.zdb
mkdir -p $runbox
echo "state_dir=_state" >$runbox/zapusk.conf
echo "############# main" >$runbox/00-main.ini
cat $arg_files >$runbox/body.ini
# приделали шапочку, и собрали все аргументы в одно тело
# а там они уже разберутся...

# запускаем
$zapusk_tool $cmd --zdb $runbox

# в будущем, когда запуск научится читать стдин, можно будет сделать так:
#echo "####### main"; cat args_*.ini; | $zapusk_tool $cmd --zdb -- --state _box.state
