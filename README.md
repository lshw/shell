# shell

\#!/bin/bash  

这个项目， 管理一些常用的脚本， 这些脚本帮助admin完成一些工作， 一般放在/usr/local/sbin目录下  
  
mirrirdir 在本机或者远程增量同步目录，支持本机到本机，本机到远程，远程到本机， 但不支持远程到远程，本机和远程需要装rsync  
port.sh 把本机的某个端口，映射到另一台主机，实现网络跳板，支持映射到不同的端口  
ports.sh 支持把本机的某一些端口，映射到另一台主机， 实现网络跳板  
back.sh 远程备份系统， 支持把多个远程主机的不同的目录文件， 备份到本机，并且建立文件每日快照  
mysqlbak.sh 做每日快照， 日备份保留最近180天， 周备份和月备份不做自动清理  
sql_dump_struct.sh 导出php业务系统的mysql库表结构， 具体使用方法， 看脚本内的注释  
