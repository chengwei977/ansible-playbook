#!/bin/sh

. /etc/profile > /dev/null 2>&1

tmpHostsFile=$1

cat ${tmpHostsFile}
if [ $? -eq 0 -a `grep [0-9] ${tmpHostsFile} | wc -l` -gt 1 ]; then 
    echo "开始将映射写入/etc/hosts"
    cat ${tmpHostsFile} |while read vline
    do
        echo $vline >> /etc/hosts
        if [ `grep "$vline" /etc/hosts > /dev/null 2>&1;echo $?` -eq 0 ]; then
            echo $vline 写入/etc/hosts成功。
        fi
    done
else
    echo "输入异常, 程序退出"
    exit 1;
fi