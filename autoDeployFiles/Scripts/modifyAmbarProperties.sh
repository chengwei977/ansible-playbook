#!/bin/bash

for i in `grep -n url /etc/ambari-server/conf/ambari.properties |grep jdbc |awk -F: '{print $1}'|xargs`
do
    sed -i ''"$i"'{s/$/?serverTimezone=UTC\&useUnicode=true\&characterEncoding=utf8\&useSSL=false/}' /etc/ambari-server/conf/ambari.properties
    grep url /etc/ambari-server/conf/ambari.properties |grep jdbc
done
