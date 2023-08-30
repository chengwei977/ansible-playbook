#!/bin/bash
. /etc/profile > /dev/null 2>&1

#请确保已经按照部署文档中事先配置好了, ansible-playbook\ansible-playbook-ambari\autoDeployFiles\Scripts\hostlist.txt中的内容以及temphosts.txt


scriptsDir=/opt/ansible-playbook/ansible-playbook-ambari/autoDeployFiles/Scripts/
cd ${scriptsDir}

if [ `rpm -qa |grep ansible > /dev/null 2>&1;echo $?` -ne 0 ]; then
    yum localinstall -y ${scriptsDir}/../../ansible-rpm/*.rpm
fi

if [ `rpm -qa |grep vsftpd > /dev/null 2>&1;echo $?` -ne 0 ]; then
    yum localinstall -y ${scriptsDir}/../rpmPackages/vsftpd-3.0.2-28.el7.x86_64.rpm
    systemctl restart vsftpd
fi

ambari_server_source=`ip a|grep -w inet|grep -v 127.0.0.1|awk '{print $2}'|awk -F/ '{print $1}'`

if [ ! -d /var/ftp/centos7 ]; then
    mkdir -p /var/ftp/centos7 
    echo "创建本地iso挂载目录"
else
    echo "/var/ftp/centos7目录已存在"
fi

if [ `df -h /var/ftp/centos7 > /dev/null 2>&1; echo $?` -ne 1 ] ; then
    mount /dev/cdrom /var/ftp/centos7 
    echo "挂载iso至/var/ftp/centos7"
else
    echo "已挂载成功,不再重复挂载"
fi

if [ ! -d /etc/yum.repos.d/bak ]; then
    mkdir -p /etc/yum.repos.d/bak
    echo "创建默认yum源备份目录"
else
    echo "/etc/yum.repos.d/bak目录已存在"
fi

if [ `ls /etc/yum.repos.d/CentOS*.repo > /dev/null 2>&1; echo $?` -eq 0 ]; then
    mv /etc/yum.repos.d/CentOS*.repo /etc/yum.repos.d/bak/.
    echo "备份默认yum源"
else
    echo "默认yum源已经备份过了,无需重复备份"
fi

systemctl stop firewalld > /dev/null 2>&1 && systemctl disable firewalld > /dev/null 2>&1
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config > /dev/null 2>&1 ; setenforce 0


cat > /etc/yum.repos.d/local.repo << EOF
[centos]
name=centos
baseurl=ftp://localhost/centos7
gpgcheck=0
enable=1
EOF

sed -i 's/localhost/'"${ambari_server_source}"'/g' /etc/yum.repos.d/local.repo
yum clean all && yum makecache

if [ `rpm -qa |grep expect > /dev/null 2>&1;echo $?` -ne 0 ]; then
    yum install -y expect
fi

cat ${scriptsDir}/temphosts.txt |awk '{print $1,$2}' | while read vIP vHost
do
    if [ `grep ${vHost} /etc/hosts > /dev/null 2>&1;echo $?` -ne 0 ]; then
        echo "${vIP} ${vHost}" >> /etc/hosts
    fi
done

sh batchSendKey.sh

for i in `cat ${scriptsDir}/temphosts.txt |awk '{print $2}' |grep -v \`hostname\`|xargs `
do
    scp /etc/hosts $i:/etc/.
done

echo [all_node] > /etc/ansible/hosts
cat ${scriptsDir}/temphosts.txt |awk '{print $2}' >> /etc/ansible/hosts

echo "" >> /etc/ansible/hosts

echo [master] >> /etc/ansible/hosts
echo `hostname` >> /etc/ansible/hosts

echo "" >> /etc/ansible/hosts

echo [slave] >> /etc/ansible/hosts
cat ${scriptsDir}/temphosts.txt |awk '{print $2}' |grep -v `hostname` >> /etc/ansible/hosts

ansible-playbook /opt/ansible-playbook/ansible-playbook-ambari/ambari.yml
