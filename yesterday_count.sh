#!/bin/bash
HOSTNAME="localhost"
PORT="3306"
USERNAME="root"
PASSWORD="root_apt1234!@#$"
DBNAME="apt"
TABLENAME="event"
TABLENAME1="asset_ipv4"


#read -p "输入所需要查看历史统计日期:" time
#echo $time

time_start=`date -d "$1 00:00:00" +%s`
time_end=`date -d "$1 23:59:59" +%s`
echo "$time_start --- $time_end"

##各个模块攻击告警数
names=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2 |cut -d "_" -f 9
select  event_type,COUNT(event_type)  from ${TABLENAME}  WHERE capture_time BETWEEN  ${time_start}  AND  ${time_end}  GROUP BY event_type ;
EOF`

all_attack_count=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
select COUNT(*)  from ${TABLENAME}  WHERE capture_time BETWEEN  ${time_start}  AND  ${time_end};
EOF`

##受损资产排名
damages=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT   ${TABLENAME}.dst_ipv4,COUNT(${TABLENAME}.dst_ipv4) FROM ${TABLENAME},${TABLENAME1} WHERE ${TABLENAME}.dst_ipv4=${TABLENAME1}.ipv4 AND  capture_time BETWEEN ${time_start}  AND  ${time_end} GROUP BY dst_ipv4 ORDER BY COUNT(dst_ipv4) DESC limit 5;
EOF`

##源端口比例
src_port=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT  src_port,COUNT(src_port) from ${TABLENAME} where capture_time  BETWEEN ${time_start}  AND  ${time_end} AND src_port !=0 GROUP BY src_port ORDER BY COUNT(src_port) DESC limit 5;
EOF`


##目的口比例
ports=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT  dst_port,COUNT(dst_port) from ${TABLENAME} where capture_time  BETWEEN ${time_start}  AND  ${time_end} AND dst_port !=0 GROUP BY dst_port ORDER BY COUNT(dst_port) DESC limit 5;
EOF`

##源IP攻击排名
src_ip=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT  src_ipv4,COUNT(src_ipv4) FROM ${TABLENAME}  WHERE capture_time BETWEEN ${time_start} AND ${time_end} GROUP BY src_ipv4 ORDER BY COUNT(src_ipv4) DESC LIMIT 5;
EOF`


##目的IP攻击排名
dst_ip=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT  dst_ipv4,COUNT(dst_ipv4) FROM ${TABLENAME}  WHERE capture_time BETWEEN ${time_start} AND ${time_end} GROUP BY dst_ipv4 ORDER BY COUNT(dst_ipv4) DESC LIMIT 5;
EOF`



echo "--------事件类型比例--------"
number=2
for i in $names
do
  res=`expr $number % 2`
  if [ "$res" -eq "0" ];then
     if [ $i -eq 1 ];then 
        echo -n  "行为告警：\t"
     elif [ $i -eq 2 ];then
        echo  -n "沙箱告警：\t"
     elif [ $i -eq 3 ];then
        echo -n "流量告警：\t"
     else [ $i -eq 4 ]
        echo -n "邮件告警：\t"
     fi
  else
     per=`echo "scale=4;($i/${all_attack_count})*100" | bc`
     percent_result=`echo $per |cut -c 1-5 ` 
     echo -n "$i \t"
     echo "占比：${percent_result}%"
  fi
  number=$(($number + 1)) 
done
echo
echo "------------受损资产排名------------"
if [ -z "$damages" ];then
   echo "暂无数据"
else
  for j in $damages
  do
     if [ $j -gt "1000000000" ];then
        num=`echo "obase=16;$j"|bc`
        a=`echo $num |cut -b -2`
        b=`echo $num |cut -b 3-4`
        c=`echo $num |cut -b 5-6`
        d=`echo $num |cut -b 7-`
        a1=$((0x$a))
        b1=$((0x$b))
        c1=$((0x$c))
        d1=$((0x$d))
        n=$(($n+1))
       echo -n "${a1}.${b1}.${c1}.${d1}: \t"
    else
       echo  " $j \t" 
    fi
  done
fi

echo
echo "-----------源端口比例---------------"
number1=2
sum1=0
for j in ${src_port}
do
  res=`expr $number1 % 2`
  if [ "$res" -ne "0" ];then
     sum1=$(($sum1 + $j))
  fi
  number1=$(($number1 + 1))
done

for i in ${src_port}
do
  res=`expr $number1 % 2`
  per1=`echo "scale=4;($i/$sum1)*100" | bc`
  percent_result1=`echo $per1 |cut -c 1-5 `

  if [ "$res" -eq "0" ];then
      echo -n "端口：$i \t"
  else
      echo -n "数量：$i \t"
      echo "占比：${percent_result1}"
  fi
  number1=$(($number1 + 1))
done


echo
echo "----------目的端口比例--------------"
number=2
sum=0
for j in $ports
do 
  res=`expr $number % 2`
  if [ "$res" -ne "0" ];then
     sum=$(($sum + $j))
  fi
  number=$(($number + 1))
done

for i in $ports
do
  res=`expr $number % 2`
  per=`echo "scale=4;($i/$sum)*100" | bc`
  percent_result=`echo $per |cut -c 1-5`

  if [ "$res" -eq "0" ];then 
      echo -n "端口：$i \t"
  else
      echo -n "数量：$i \t"
      echo "占比：${percent_result}"
  fi
  number=$(($number + 1)) 
done

echo 
echo "-----------源IP攻击排名-------------"
if [ -z "${src_ip}" ];then
   echo "暂无数据"
else
  for j in ${src_ip}
  do
     if [ $j -gt "1000000000" ];then
        num=`echo "obase=16;$j"|bc`
        a=`echo $num |cut -b -2`
        b=`echo $num |cut -b 3-4`
        c=`echo $num |cut -b 5-6`
        d=`echo $num |cut -b 7-`
        a1=$((0x$a))
        b1=$((0x$b))
        c1=$((0x$c))
        d1=$((0x$d))
        n=$(($n+1))
       echo -n "${a1}.${b1}.${c1}.${d1}: \t"
    else
       echo  " $j \t" 
    fi
  done
fi
echo
echo "-----------目的IP攻击排名------------"
if [ -z "${dst_ip}" ];then
   echo "暂无数据"
else
  for j in ${dst_ip}
  do
     if [ $j -gt "1000000000" ];then
        num=`echo "obase=16;$j"|bc`
        a=`echo $num |cut -b -2`
        b=`echo $num |cut -b 3-4`
        c=`echo $num |cut -b 5-6`
        d=`echo $num |cut -b 7-`
        a1=$((0x$a))
        b1=$((0x$b))
        c1=$((0x$c))
        d1=$((0x$d))
        n=$(($n+1))
       echo -n "${a1}.${b1}.${c1}.${d1}:\t"
    else
       echo  " $j \t" 
    fi
  done
fi




echo "------------------------"



