#!/bin/bash
#本脚本用于把php业务系统的数据库结构， 导出成sql.php, 方便进入git进行管理,
#脚本会读取业务系统目录下的config.php , 解析出各种配置信息，可以根据需要自行修改解析程序

if ! [ "$1" ] ; then
  echo use: $0 /home/water
  exit
fi

if [ -x $1/config.php ] ; then
  echo file $1/config.php not exists.
  exit
fi

#解析数据库配置信息
cd $1
user=$( cat config.php  |grep "^\$dbusername" |tail -n 1|sed "s/.*'\(.*\)';.*/\1/g" )
server=$( cat config.php  |grep "^\$servername" |tail -n 1|sed "s/.*'\(.*\)';.*/\1/g" )
port=$( cat config.php  |grep "^\$serverport" |tail -n 1|sed "s/.*'\(.*\)';.*/\1/g" )
db=$( cat config.php  |grep "^\$dbname" |tail -n 1|sed "s/.*'\(.*\)';.*/\1/g" )
passwd=$( cat config.php  |grep "^\$dbpasswd" |tail -n 1|sed "s/.*'\(.*\)';.*/\1/g" )

if ! [ "$user" ] ; then 
  echo not find \$username in $1/config.php
  exit
fi

if ! [ "$server" ] ; then
  echo not find \$servername in $1/config.php
  exit
fi

if ! [ "$port" ] ; then
  port=3306
fi

if ! [ "$db" ] ; then
  echo not find \$dbname in $1/config.php
  exit
fi

if ! [ "$passwd" ] ; then
  echo not find \$dbpasswd in $1/config.php
  exit
fi

echo "<?php
/*" >sql.php
 mysqldump  --no-data -u $user -h $server -P $port -p$passwd $db |grep -v -e '^--' -e "^/\*" -e '^DROP' |sed  "s/ AUTO_INCREMENT=[0-9]*//" |sed  '/^$/d' |sed 's/;/;\n/g' >>sql.php
 echo \*/ >>sql.php

