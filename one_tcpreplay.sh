#!/bin/bash

#cd /home/zxapt/dwei_test
loop=1
mbps=200 
dir=/home/zxapt/dwei_test

if [ -d "$dir/one_replay.txt" ];then
   touch $dir/one_replay.txt
else
  :>$dir/one_replay.txt
fi

echo "`date |cut -d " " -f 4`"
#:>/home/zxapt/dwei_test/one_replay.txt
sudo tcpreplay --mbps=$mbps --intf1=eth1 --loop=$loop $dir/pcaps/download_tcp/$1>$dir/one_replay.txt 2>/dev/null
failed=`cat $dir/one_replay.txt  |grep "Failed packets" |cut -d":" -f2`

if [ "$failed" -eq "0" ];then
   echo "success"
else
   echo "fail"
fi
