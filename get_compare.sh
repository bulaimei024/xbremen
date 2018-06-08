#!/bin/bash
dir=/mnt/disk/auto_test
ssh  -t -t  -p 28022  root@192.168.224.64 "bash /mnt/disk/auto_test/compare.sh"

#last=`head -n 1 $dir/test.txt`
#echo "$last"

