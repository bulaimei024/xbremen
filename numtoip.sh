#!/bin/bash

read -p "������ת��������:" ip
#echo $ip
num=`echo "obase=16;$ip"|bc`

a=`echo $num |cut -b -2`
b=`echo $num |cut -b 3-4`
c=`echo $num |cut -b 5-6`
d=`echo $num |cut -b 7-`

a1=$((0x$a))
b1=$((0x$b))
c1=$((0x$c))
d1=$((0x$d))

echo
echo -n "���յõ���IP�ǣ� "
echo "${a1}.${b1}.${c1}.${d1}"
