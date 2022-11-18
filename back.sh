#!/bin/bash

#用ssh跑rsync，备份远程主机到本机，并且做每日快照
#远程主机需要安装rsync和ssh服务，
#本机需要装rsync和btrfs-tools,
#需要在本机生成ssh密钥对， 并复制ssh公钥到远程主机,以便不需要密码登录对方的ssh服务
#本机没有私钥的话， 生成私钥：ssh-keygen, 复制公钥到远程:ssh-copy-id 192.168.1.1
#备份的保存主目录 在命令行参数1, 如果不存在参数1,那就用本备份文件所在的目录做保存目录
#备份的服务器列表在 保存主目录下的back.txt 每行用空格间隔2个参数， 前面是目录名，后面的是服务器地址
#每个远程主机的etc目录 以及远程主机的etc/bak.list里列出来的每一个目录，都会备份回来
#要求bakpath是建立在btrfs文件系统上， 使用btrfs的快照功能实现每日快照
#https://github.com/lshw/shell/back.sh

function rsynca
{
 #调用例子: rsynca  192.168.1.1:/etc  route/etc
 #备份192.168.1.1的 /etc 到 $bakpath/route/etc 最大文件700M
 hosta=`echo $1 |awk -F: '{print $1}'`
 hosta=${hosta%:*}
 ping $hosta -c 3 -W 5 >/dev/null 2>/dev/null
 if [ $? != 0 ] ; then
  echo $hosta $2 不通 >>$bakpath/remotebak0.log
  return
 fi

 echo $bakpath/$2 >/tmp/bakpath.txt
 mkdir -p $bakpath/$2
 echo ==${2}================ >> ${bakpath}/remotebak0.log
 echo `date '+%Y-%m-%d %H:%M:%S'` rsynca to $bakpath/$2 >> ${bakpath}/remotebak0.log
 a=0
 while [ 1 ]
 do
  #	if [ "`basename $1`" == "mysql" ] ; then
  #		echo mysql  time
  #	fi
  echo "rsync -8rlHtopgSz  --delete-excluded  --exclude=*.log.gz --exclude=*.log.*.gz --delete-before --max-size 700M --timeout=1200 --rsh='ssh -p${port}' --progress $3 $1 $bakpath/$2" >$bakpath/$hname/remotebak1.log 
  rsync -8rlHtopgSz  --delete-excluded  --exclude=*.log.gz --exclude=*.log.*.gz --delete-before --max-size 700M --timeout=1200 --rsh="ssh -p${port}" --progress $3 $1 $bakpath/$2  >> ${bakpath}/$hname/remotebak1.log
  if [ $? == 0 ] ; then
   touch $bakpath/$2/bak.ok
   break;
  fi
  a=$(( $a + 1 ))
  if [ $a == 4 ] ; then
   #tail -n 2 $bakpath/$hname/remotebak1.log >> $bakpath/remotebak0.log
   echo error  $a  `date '+%Y-%m-%d %H:%M:%S'` >> $bakpath/remotebak0.log
   return
  fi
  sleep 30
 done
 #tail -n 2 $bakpath/$hname/remotebak1.log >> $bakpath/remotebak0.log
 echo ok  `date '+%Y-%m-%d %H:%M:%S'`  >> $bakpath/remotebak0.log
} #function rsynca end

function rsyncb() {
 #使用:rsyncb 192.168.1.1 route
 #备份192.168.1.1系统到 $bakpath/route 要备份的目录在 192.168.1.1:/etc/bak/list设置。 一行一个目录
 host=${1%:*}
 port=${1#*:}  #todo 支持非22端口 192.168.1.1:222
 export hname=$2
 ping $host -c 3 -W 5 >/dev/null 2>/dev/null
 if [ $? != 0 ] ; then
  echo $host $2 不通 >>$bakpath/remotebak0.log
  echo $host $2 不通 
  return
 fi
 if [ "a$port" == "a" ] ; then
  port=22
 fi
 if [ "$port" == "$1" ] ; then
  port=22
 fi

 unset add
 if ! [ "a$3" == "a" ]; then
  if [ "${3:0:1}" == "/" ] ; then
   add=$host:$3
  else
   add=$host:/$3
  fi
 fi
 #先备份 /etc目录，
 rsynca "${host}:/etc/" $2/etc/
 #再根据  被备份系统的/etc/bak.list 设置，备份其它目录
cat $bakpath/$2/etc/bak.list |while read a txt
 do
  dir=`echo $a |tr -d "\r\n \t\."`
  if [ "$dir" != "" ] ; then
   echo $dir
   #	if [ "`basename $dir`" == "mysql" ] ; then
   #		echo mysql  time
   #	fi
   rsynca "${host}:/$dir/" $2/$dir/
  fi
 done
 touch $bakpath/$2
} #function rsyncb end
#function区 结束

if ! [ "$bakpath" ] ;then
 if [ "a$1" != "a" ] ; then
  if [ -x "$1" ] ; then
   bakpath=$1
  fi
 fi
 if [ "a$bakpath" = "a" ] ;then
  bakpath=`dirname $0`
 fi
fi
bakpath=`realpath $bakpath`
if [ ! -e "$bakpath/back.txt" ] ; then
 echo 没有找到 $bakpath/back.txt
 exit
fi
echo 备份目标目录 $bakpath
mkdir -p $bakpath
touch $bakpath
export bakpath=$bakpath
if [ `date +%d` == '01' ] ; then
 dir=M`date +%m` #每月1号，建立月备份bak_M01，会每年覆盖一次，如果月备份想永久保留， 改成date +%Y%m  目录为 bak_M202001
else
 week=`date +%w`
 if [ "$week" == "6" ] ; then
  dir=W`date +%W` #每周日做一个周备份 bak_W01 保留1年循环备份
 else
  dir=week`date +%w` #每天做一个日备份，循环保留一周，目录是 bak_week01.bak,_week02...
 fi
fi

#建立每日只读快照
mkdir -p ${bakpath}_snapshot
snapshot=${bakpath}_snapshot/$dir
echo 建立快照 $snapshot
if [ -x $snapshot ] ; then
 btrfs sub delete $snapshot
fi
btrfs sub snapshot -r $bakpath $snapshot
btrfs sub delete ${bakpath}_snapshot/now
btrfs sub snapshot -r $bakpath ${bakpath}_snapshot/now
echo > $bakpath/remotebak0.log

#单个备份
#rsyncb 192.168.14.1 al-lims

cat $bakpath/back.txt |while read name host txt
do
  if [ "a$host" == "a" ] ; then
    continue
  fi
  name=`basename $name|tr -d ' \t\.\\/'`
  if [ ${name:0:1} == "#" ] ; then
    continue
  fi
  if [ "`ifconfig |grep $host`" ] ; then
    continue
  fi
  echo $name $host
  rsyncb   $host $name
done

df -h $bakpath >$bakpath/df.txt
#mirrordir $bakpath 192.168.2.5:/home/lims
cat $bakpath/remotebak0.log >> $bakpath/remotebak.log



