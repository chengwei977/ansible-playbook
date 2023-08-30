#!/bin/bash
. /etc/profile > /dev/null 2>&1

port=$1
password=$2
java_home=$3
hostname=$4
driver=$5

if [ ! -f /usr/lib/ambari-server/lib/ambari_server/dbConfiguration.py.bak ] ; then
    cp /usr/lib/ambari-server/lib/ambari_server/dbConfiguration.py /usr/lib/ambari-server/lib/ambari_server/dbConfiguration.py.bak
    sed -i '438s/Enter choice/PleaseEnter/g' /usr/lib/ambari-server/lib/ambari_server/dbConfiguration.py
else
    rm -f /usr/lib/ambari-server/lib/ambari_server/dbConfiguration.py && mv /usr/lib/ambari-server/lib/ambari_server/dbConfiguration.py.bak /usr/lib/ambari-server/lib/ambari_server/dbConfiguration.py
    sed -i '438s/Enter choice/PleaseEnter/g' /usr/lib/ambari-server/lib/ambari_server/dbConfiguration.py
fi

setup_ambari() {
  #yum -y install expect >/dev/null 2>&1
  expect -c "
      set timeout -1;
      spawn ambari-server setup;
      expect {
          continue*                                                     {send -- y\r;exp_continue;}
          Customize*                                                    {send -- n\r;exp_continue;}
          change*                                                       {send -- y\r;exp_continue;}
          choice*                                                       {send -- 2\r;exp_continue;}
          JAVA_HOME*                                                    {send -- $java_home\r;exp_continue;}
          install*                                                      {send -- n\r;exp_continue;}
          configuration*                                                {send -- y\r;exp_continue;}
          PleaseEnter*                                                      {send -- 3\r;exp_continue;}
          Hostname*                                                     {send -- $hostname\r;exp_continue;}
          Port*                                                         {send -- ${port}\r;exp_continue;}
          name*                                                         {send -- \r;exp_continue;}
          Username*                                                     {send -- \r;exp_continue;}
          Password*                                                     {send -- ${password}\r;exp_continue;}
          Re-enter*                                                     {send -- ${password}\r;exp_continue;}
          driver*                                                       {send -- ${driver}\r;exp_continue;}
          connection*                                                   {send -- y\r;exp_continue;}
          eof                                                           {exit 0;}
      };"
}
setup_ambari
