#!/bin/bash
if [ ! -f ~/.ssh/id_rsa ];then
  ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
else
 echo "id_rsa has created ..."
fi
 
while read line
  do
    user="root"
    ip=`echo $line | cut -d " " -f 1`
    passwd=`echo $line | cut -d " " -f 2`
    expect <<EOF
      set timeout 10
      spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $user@$ip
      expect {
        "yes/no" { send "yes\n";exp_continue }
        "password" { send "$passwd\n" }
      }
      expect "password" { send "$passwd\n" }
EOF
  done <  hostlist.txt
