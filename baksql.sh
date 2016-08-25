#!/bin/bash


basedir=/home/sqlbak

cp $0 $basedir

find ${basedir}/day  -mtime +21  -exec rm {} \; #日备份保留21天
find ${basedir}/week -mtime +180 -exec rm {} \; #周备份保留180天

bakdir=${basedir}/day
datew=`date +%w`
if [ "5" == $datew ]  ; then  #周5
bakdir=${basedir}/week 
fi

datem=`date +%e`
if [ " 1" == $datem ] ; then    #每月1号
bakdir=${basedir}/month
fi

time=`date  +%G%m%d`
password=******
userid=root

host=localhost

db=mysql
mysqldump  --host=$host --add-drop-table -c  --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9 |gpg  -e -r "anheng admin" --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=net
mysqldump  --host=$host --add-drop-table -c  --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r "anheng admin" --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=watertest
mysqldump  --host=$host --add-drop-table -c  --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=news
mysqldump  --host=$host --add-drop-table -c  --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=bbs
mysqldump  --host=$host --add-drop-table -c  --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=wikidb
mysqldump  --host=$host --add-drop-table -c  --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=dian
mysqldump  --host=$host --add-drop-table -c  --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg
scp ${bakdir}/*_$time.sql.bz2.gpg 192.168.11.2:${bakdir}

cd /home
#tar cvfj cvsroot.tar.bz2 cvsroot
gpg -r 1c953423 --yes --batch -o ${basedir}/cvsroot.tar.bz2.gpg -e cvsroot.tar.bz2
rm /home/cvsroot.tar.bz2


userid=bak
password=********
host=127.0.0.1
port=3307

#/下面数据库都是用从库，不需要担心压缩造成长时间锁表的问题
db=anheng
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=netproducts
mysqldump  --host=$host -P${port}--add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=waternews
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=waterproducts
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

db=vpopmail
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg
db=925feicuiproducts
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg
db=925products
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg
db=loongson
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg
db=sasu
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg
db=sz812
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg
db=sjnjzx
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg
db=gb
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg
db=xmb
mysqldump  --host=$host -P${port} --add-drop-table -c --allow-keywords --force --password=$password --user=$userid $db  |bzip2 -9|gpg -e -r 1c953423 --yes --batch -o ${basedir}/now/${host}_${db}.sql.bz2.gpg
cp ${basedir}/now/${host}_${db}.sql.bz2.gpg ${bakdir}/${host}_${db}_$time.sql.bz2.gpg

