#!/bin/bash
#创建mysql用户

sudo groupadd mysql
sudo useradd -g mysql mysql

MySQLDir=$1
MySQLVersion=$2
MySQLConfDir=$3

systemctl stop mysqld > /dev/null 2>&1
#rm -rf /data/mysql > /dev/null 2>&1
#rm -rf /usr/local/mysql > /dev/null 2>&1

#下载二进制安装文件，并解压至/usr/local/mysql

sudo tar -xf ${MySQLDir}/${MySQLVersion}-el7-x86_64.tar.gz -C /usr/local/.
sudo mv /usr/local/${MySQLVersion}-el7-x86_64 /usr/local/mysql
sudo chown -R mysql:mysql /usr/local/mysql

ln -s /usr/local/mysql/bin/mysql /bin/mysql

#添加环境变量
#sudo echo "PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
#source /etc/profile

#创建数据目录
sudo mkdir -p /data/mysql/{data,log,binlog,conf,tmp}
sudo chown -R mysql:mysql /data/mysql

#配置MySQL
cp ${MySQLConfDir}/my.cnf /data/mysql/conf/


#初始化mysql
/usr/local/mysql/bin/mysqld --defaults-file=/data/mysql/conf/my.cnf  --initialize-insecure  --user=mysql

#添加mysql服务及设置自启动

cp ${MySQLConfDir}/mysqld.service /etc/systemd/system/.

#启动服务
systemctl start mysqld

#开启自启动
systemctl enable mysqld
