#!/bin/sh
# author: beimenchuixue
# blog: http://www.cnblogs.com/2bjiujiu/

phpPath="/application/php"
nginxPath="/application/nginx"

if [ -d $phpPath -a -d $nginxPath ]; then
    echo "php and nginx has installed"
else
    echo "php and nginx not install"
    exit 1
fi

function sureOK {
    [ $1 -eq 0 ] && {
        echo "$2 ok"
    } || {
        echo "$2 faile"
    }
}

function phpConf {
    \cp $phpPath/etc/php-fpm.conf.default $phpPath/etc/php-fpm.conf
    sureOK $? "php-fpm.conf"
    \cp $phpPath/etc/php-fpm.d/www.conf.default $phpPath/etc/php-fpm.d/www.conf
    sureOK $? "php-fpm.d/www.conf"
}
# phpConf

function startFastcgi {
    $phpPath/sbin/php-fpm
    sureOK $? "startFastcgi"
    echo "$phpPath/sbin/php-fpm" >> /etc/rc.local
}
# startFastcgi

function nginxConf {
    echo -e "worker_processes  1;\nevents {\n\tworker_connections  1024;\n}\nhttp {\n\tinclude       mime.types;\n\tdefault_type  application/octet-stream;\n\tsendfile        on;\n\tkeepalive_timeout  65;\n\tinclude extra/*.conf;\n}\n" > $nginxPath/conf/nginx.conf
    sureOK $? "write nginxConf"
    cd $nginxPath/conf
    mkdir extra -p
    sureOK $? "nginx extra confdir"
}
# nginxConf

function blogServer {
    cd $nginxPath/conf/extra
    cat >>blog.conf<<EOF
server {
    listen       80;
    server_name  blog.beimenchuixue.com;
    location / {
         root   html/blog;
         index  index.php index.html index.htm;
    }
    location ~* .*\.(php|php5|php7)?$ {
        root    html/blog;
        fastcgi_pass    127.0.0.1:9000;
        fastcgi_index   index.php;
        include fastcgi.conf;
    }
}
EOF
    sureOK $? "blog server"
    mkdir -p $nginxPath/html/blog
    sureOK $? "mkdir html/blog"
}

# blogServer

function startNginx {
    echo "$nginxPath/sbin/nginx" >> /etc/rc.local
    $nginxPath/sbin/nginx -t
    sureOK $? "start nginx"
}
# startNginx


function blogTest {
    echo "<?php  phpinfo();?>" > $nginxPath/html/blog/index.php
    sureOK $? "init test index.php"
    localIp=$(ip a show dev eth0|awk -F "[ /]+" 'NR==3{print $3}')
    webStatus=`curl -I -m 10 -o /dev/null -s -w %{http_code} $localIp`
    [ $webStatus -eq 200 ] && {
        sureOK 0 "blog work"
    } || {
        sureOK 1 "blog faile"
    }
}
blogTest

# phpConfig
