#!/bin/bash
HOSTNAME="localhost"
PORT="3306"
USERNAME="root"
PASSWORD="root_apt1234!@#$"
DBNAME="apt"
TABLENAME="event"
TABLENAME1="asset_ipv4"
time=`date +%Y%m%d`
time_start=`date -d "${time} 00:00:00" +%s`
time_end=`date -d "${time} 23:59:59" +%s`

#echo "s=${time_start} e=${time_end}"
##今日攻击总数
attack_all=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT COUNT(*) FROM ${TABLENAME}  WHERE capture_time BETWEEN ${time_start}  AND  ${time_end};
EOF` 


##资产受损总数
damage=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT count(DISTINCT dst_ipv4) FROM ${TABLENAME}  WHERE  capture_time BETWEEN ${time_start}  AND  ${time_end} AND dst_ipv4 LIKE '32%';
EOF` 
##各个模块攻击告警数
names=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2 |cut -d "_" -f 9
select  event_type,COUNT(event_type)  from ${TABLENAME}  WHERE capture_time BETWEEN  ${time_start}  AND  ${time_end}  GROUP BY event_type ;
EOF`

##受损资产
damage_all=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT count(DISTINCT dst_ipv4) FROM ${TABLENAME}  WHERE  capture_time BETWEEN ${time_start}  AND  ${time_end} AND dst_ipv4;
EOF`

damages=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT   ${TABLENAME}.dst_ipv4,COUNT(${TABLENAME}.dst_ipv4) FROM ${TABLENAME},${TABLENAME1} WHERE ${TABLENAME}.dst_ipv4=${TABLENAME1}.ipv4 AND  capture_time BETWEEN ${time_start}  AND  ${time_end} GROUP BY dst_ipv4 ORDER BY COUNT(dst_ipv4) DESC ;
EOF`

#echo "all=$damage_all s=$damages"

##时间段攻击总数
tt=`date +%H`
if [ "$tt" -ge "10" ];then
  time_hour=`date +%H`
else
  time_hour=`date +%H |sed 's/0//g'`
fi

time_hour1=$((${time_hour} -1 ))
time_hour2=$((${time_hour} -2 ))
time_hour3=$((${time_hour} -3 ))

#echo ${time_hour1}
time_s=`date -d "$time ${time_hour}:00:00" +%s`
time_e=`date -d "$time ${time_hour}:59:59" +%s`
time_s1=`date -d "$time ${time_hour1}:00:00" +%s`
time_e1=`date -d "$time ${time_hour1}:59:59" +%s`
time_s2=`date -d "$time ${time_hour2}:00:00" +%s`
time_e2=`date -d "$time ${time_hour2}:59:59" +%s`
time_s3=`date -d "$time ${time_hour3}:00:00" +%s`
time_e3=`date -d "$time ${time_hour3}:59:59" +%s`



hour_count=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT count(*) FROM ${TABLENAME}  WHERE capture_time BETWEEN  ${time_s} AND ${time_e};
EOF`

hour_count1=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT count(*) FROM ${TABLENAME}  WHERE capture_time BETWEEN  ${time_s1} AND ${time_e1};
EOF`

hour_count2=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT count(*) FROM ${TABLENAME}  WHERE capture_time BETWEEN  ${time_s2} AND ${time_e2};
EOF`

hour_count3=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
SELECT count(*) FROM ${TABLENAME}  WHERE capture_time BETWEEN  ${time_s3} AND ${time_e3};
EOF`


echo
echo "--------今日告警统计---------"
echo "今日攻击总数: ${attack_all}       "
echo "资产受损总数: ${damage}     "
#for i in $names
#do 
#  if [ $i -eq 1 ];then 
#     echo -n  "行为告警："
#  elif [ $i -eq 2 ];then
#     echo  -n "沙箱告警："
#  elif [ $i -eq 3 ];then
#     echo -n "流量告警："
#  elif [ $i -eq 4 ];then
#     echo -n "邮件告警："
#  else
#     echo  "$i"
#  fi
#done
number=2
for i in $names
do
  res=`expr $number % 2`
  if [ "$res" -eq "0" ];then
     if [ $i -eq 1 ];then 
        echo -n  "行为告警："
     elif [ $i -eq 2 ];then
        echo  -n "沙箱告警："
     elif [ $i -eq 3 ];then
        echo -n "流量告警："
     elif [ $i -eq 4 ];then
        echo -n "邮件告警："
     else
        echo  "$i"
     fi
  else
    echo $i
  fi
  number=$(($number + 1)) 
done
echo
echo "----------受损资产------------"

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
       echo -n "${a1}.${b1}.${c1}.${d1}: "
    else
       echo  " $j" 
    fi
  done
  per=`echo "scale=4;($n/$damage_all)*100" | bc`
  percent_result=`echo $per |cut -c 1-4`
  echo "受损资产占比为：${percent_result}%"
fi
echo
echo "--------时间段攻击总数---------"
echo "$time ${time_hour}时，攻击总数：$hour_count"
echo "$time ${time_hour1}时，攻击总数：$hour_count1"
echo "$time ${time_hour2}时，攻击总数：$hour_count2"
echo "$time ${time_hour3}时，攻击总数：$hour_count3"

echo "------------------------------"

