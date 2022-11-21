#!/bin/bash
# /usr/local/sbin/ports.sh  remote_ip  port_min port_max
if [ "a$2" == "a" ] ;then
 echo $0 remote_ip port [port_max]
 exit
fi

if [ "a$3" == "a" ] ;then
 ports=$2
else
 if [ "a$3" == "a$2" ] ; then
  ports=$2
 else
  ports=$2:$3
 fi
fi

local_eth=`ip -4 route list |grep default |head -n 1 |awk '{printf $5}'`

local_ip=`ip -4 addr list dev $local_eth |grep 'inet ' |tr '/' ' ' |awk '{print $2}'`
remote_ip=$1
if [ "$local_ip" == "$remote_ip" ] ; then
 exit
fi

echo 1 >/proc/sys/net/ipv4/ip_forward

iptables -t nat -L -n >/tmp/${remote_ip}_${2}.log

if ! [ "`grep ^DNAT /tmp/${remote_ip}_${2}.log |grep ${remote_ip}|grep ${ports} |grep ${local_ip}|grep tcp`" ] ; then
 iptables -t nat -I PREROUTING -d $local_ip -p tcp -m multiport --dport $ports -j DNAT --to $remote_ip
fi
if ! [ "`grep ^DNAT /tmp/${remote_ip}_${2}.log |grep ${remote_ip}|grep ${ports} |grep ${local_ip}|grep udp`" ] ; then
 iptables -t nat -I PREROUTING -d $local_ip -p udp -m multiport --dport $ports -j DNAT --to $remote_ip
fi
if ! [ "`grep ^SNAT /tmp/${remote_ip}_${2}.log |grep ${remote_ip}|grep ${local_ip}`" ] ; then
 iptables -t nat -I POSTROUTING -d $remote_ip  -j SNAT --to $local_ip
fi
rm /tmp/${remote_ip}_${2}.log
