#!/bin/bash

#在basedir 目录下，会建立一个mysqlbak.txt 里面是库名， 一行一个, 可以修改， 把需要的库名列进去
 
basedir=/home/sqlbak
mysql_passwd=******
mkdir -p $basedir
if ! [ -e $basedir/mysqlbak.txt ] ; then
 echo mysql >$basedir/mysqlbak.txt
 echo water >>$basedir/mysqlbak.txt
fi

mkdir -p ${basedir}/day ${basedir}/week ${basedir}/month
find ${basedir}/day -type f  -mtime +31  -exec rm {} \; 
find ${basedir}/week -type f  -mtime +365  -exec rm {} \; 
bakdir=${basedir}/day
datew=`date +%w`
if [ "5" == "$datew" ] 
then
bakdir=${basedir}/week
fi

datem=`date +%e`
if [ " 1" == "$datem" ]
then
bakdir=${basedir}/month
fi

time=`date  +%G%m%d`
#/etc/init.d/mysql stop  >/dev/null 2>/dev/null

mkdir -p $bakdir
cd $bakdir
rm -f *.sql $time.tar.xz *.tar
cat $basedir/mysqlbak.txt |while read dbname
do
 dbname0=`basename $dbname`
 mysqldump -u root -p$mysql_passwd $dbname0 >$dbname0.sql 2>/dev/null
done
tar cfJ $time.tar.xz *.sql
rm -f *.sql *.tar

if [ "`find $bakdir -name '$time.tar.xz' -size -1000k `" ] ; then
echo size too small
ls -l $bakdir/$time.tar.xz
fi

