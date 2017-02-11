#!/bin/bash
# /usr/local/sbin/ports.sh  remote_ip  port_min port_max
if [ "a$3" == "a" ] ;then
echo $0 remote_ip port_min port_max
exit
fi
local_ip=`ifconfig |grep 'inet addr' |grep -v 127.0.0 |tr ':' ' '|awk '{print $3}'|grep -v '^10.'|grep -v '^192.168.'|grep -v '^172.'`
remote_ip=$1
port_min=$2
port_max=$3

iptables -t nat -D PREROUTING -d $local_ip -p udp -m multiport --dport $port_min:$port_max -j DNAT --to $remote_ip
iptables -t nat -A PREROUTING -d $local_ip -p udp -m multiport --dport $port_min:$port_max -j DNAT --to $remote_ip
iptables -t nat -D PREROUTING -d $local_ip -p tcp -m multiport --dport $port_min:$port_max -j DNAT --to $remote_ip
iptables -t nat -A PREROUTING -d $local_ip -p tcp -m multiport --dport $port_min:$port_max -j DNAT --to $remote_ip
iptables -t nat -D POSTROUTING -d $remote_ip  -j SNAT --to $local_ip
iptables -t nat -A POSTROUTING -d $remote_ip  -j SNAT --to $local_ip
