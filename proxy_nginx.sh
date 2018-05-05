#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

nginxConfPath="/application/nginx/conf"
cpuCores=$(grep "cpu cores" /proc/cpuinfo |awk -F "[ :]+" '{print $3}')
workerConnection="1024"
serverName="www.yunhello.cn"
serverPort="80"
poolName="www_server_pools"
confName="nginx.conf"
serverIP="172.16.1.8 172.16.1.9"

[ -d $nginxConfPath ] || {
    echo "nginx not install"
    echo "$nginxConfPath not exist"
    exit 1
}

upstreamLineNum=$(sed -n "/upstream/=" $nginxConfPath/$confName)

. /etc/init.d/functions

function sureOk {
    [ $1 -eq 0 ] && {
        action "$2 is"  /bin/true
    } || {
        action "$2 is"  /bin/false
    }
}

function initProxyConf {
    cd $nginxConfPath
    cat /dev/null > $confName
    sureOk $? "clear $confName"
    cat >>$confName<<EOF
worker_processes  $cpuCores;
events {
    worker_connections  $workerConnection;
}

http {
    upstream $poolName {
    }
    server {
        listen       $serverPort;
        server_name  $serverName;
        location / {
            proxy_pass http://$poolName;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-For \$remote_addr;
         }
    }
}
EOF
    sureOk $? "initProxyConf"
}
# initProxyConf

function initProxyServer {
    for ip in $serverIP
    do
       sed -i "${upstreamLineNum}a \        server $ip:80 weight=1;" $nginxConfPath/$confName
    done
    sureOk $? "initProxyServer"
}
# initProxyServer

function main_beinMenChuiXue {
    initProxyConf
    initProxyServer
}
main_beinMenChuiXue
