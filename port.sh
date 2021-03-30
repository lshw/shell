#!/bin/bash
# /usr/local/sbin/ports.sh  remote_ip  port_min port_max
if [ "a$2" == "a" ] ;then
 echo $0 from_port remote_ip:to_port
 exit
fi

local_eth=`ip route list |grep default|awk '{printf $5}'`

local_ip=`ifconfig $local_eth |grep 'inet addr' |tr ':' ' '|awk '{print $3}'`
if [ "a$local_ip" == "a" ] ; then
 local_ip=`ifconfig $local_eth |grep 'inet ' |awk '{print $2}'`
fi
local_port=$1
remote_ip=${2%:*}
remote_port=${2#*:}

if [ "a$remote_port" == "a" ] ; then
 remote_port=$local_port
fi

echo 1 >/proc/sys/net/ipv4/ip_forward

iptables -t nat -L -n >/tmp/${remote_ip}_${remote_port}.log

if ! [ "`grep ^DNAT /tmp/${remote_ip}_${remote_port}.log |grep ${remote_ip} |grep ${remote_port} |grep $local_port |grep ${local_ip}|grep tcp`" ] ; then
 iptables -t nat -I PREROUTING -d $local_ip -p tcp --dport $local_port -j DNAT --to $remote_ip:$remote_port
fi

if ! [ "`grep ^DNAT /tmp/${remote_ip}_${remote_port}.log |grep ${remote_ip} |grep ${remote_port} |grep $local_port |grep ${local_ip}|grep udp`" ] ; then
 iptables -t nat -I PREROUTING -d $local_ip -p udp --dport $local_port -j DNAT --to $remote_ip:$remote_port
fi

if ! [ "`grep ^SNAT /tmp/${remote_ip}_${remote_port}.log |grep ${remote_ip}|grep ${local_ip}`" ] ; then
 iptables -t nat -I POSTROUTING -d $remote_ip  -j SNAT --to $local_ip
fi
rm /tmp/${remote_ip}_${remote_port}.log
