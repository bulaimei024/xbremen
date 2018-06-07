#!/bin/bash
HOSTNAME="localhost"
PORT="3306"
USERNAME="root"
PASSWORD="root_apt1234!@#$"
DBNAME="sandbox"
TABLENAME="malwareinfo"

#select_sql="select filename from  ${TABLENAME} where score<=200"
#select_sql="select count(*) from  ${TABLENAME} where score>200"
#mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} -e "${select_sql}"

harmful=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
select count(*) from ${TABLENAME} where score>=200;
EOF` 

all=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2
select count(*) from ${TABLENAME};
EOF`

name=`mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} ${DBNAME} 2>/dev/null <<EOF |tail -n +2 |cut -d "_" -f 9
select filename from ${TABLENAME} where score>=200;
EOF`


for filename in $name
do
  echo Filename:$filename
done

#percent=$(printf "%.2f" `echo "scale=2;$youhai/$all" |bc`) 
percent=`echo "scale=4;($harmful/$all)*100" | bc`
percent_result=`echo $percent |cut -c 1-5`


echo "The number of Harmful is $harmful"
echo "The sandbox all is $all"
echo "The Harmful% is ${percent_result}%"

