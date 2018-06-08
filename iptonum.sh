#!/bin/bash
read -p "请输入IPV4地址:" ip
#echo "$ip"
a=`echo $ip |awk -F "." '{print $1}'`
b=`echo $ip |awk -F "." '{print $2}'`
c=`echo $ip |awk -F "." '{print $3}'`
d=`echo $ip |awk -F "." '{print $4}'`

a1=`echo "ibase=10;obase=16;$a"|bc`
b1=`echo "ibase=10;obase=16;$b"|bc`
if [ $c -le 15 ];then
  c1=0`echo "ibase=10;obase=16;$c"|bc`
else
  c1=`echo "ibase=10;obase=16;$c"|bc`
fi
if [ $d -le 15 ];then
  d1=0`echo "ibase=10;obase=16;$d"|bc`
else
  d1=`echo "ibase=10;obase=16;$d"|bc`
fi

all=$a1$b1$c1$d1
echo
echo -n "最终转化成数字为---"
echo $((0x$all))
