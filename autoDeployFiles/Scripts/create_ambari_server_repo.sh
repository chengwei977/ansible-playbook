#!/bin/sh
. /etc/profile > /dev/null 2>&1

#ambari server源地址

if [ $# -eq 1 ] ;then
    ambari_server_source=$1
else
    ambari_server_source=`ip a|grep -w inet|grep -v 127.0.0.1|awk '{print $2}'|awk -F/ '{print $1}'`
fi

#自动配置本地源
mount /dev/cdrom /mnt && mkdir -p /etc/yum.repos.d/bak && mv /etc/yum.repos.d/CentOS*.repo /etc/yum.repos.d/bak/.

cat > /etc/yum.repos.d/local.repo << EOF
[ambari]
name=ambari
baseurl=ftp://192.168.0.97/ambari/centos7/2.7.6.0-4
gpgcheck=0
enable=1

[centos]
name=centos
baseurl=ftp://192.168.0.97/centos7
gpgcheck=0
enable=1
EOF

sed -i 's/192.168.0.97/'"${ambari_server_source}"'/g' /etc/yum.repos.d/local.repo

yum clean all && yum makecache
