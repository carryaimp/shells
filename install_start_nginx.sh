#!/bin/sh

# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

 . /etc/init.d/functions

install_path="/application"
nginx_package_name="nginx-1.12.2.tar.gz"
nginx_download_url="http://nginx.org/download/$nginx_package_name"
nginx_run_user="nginx"
down_path="$HOME/tools"
nginx_relay="pcre-devel openssl-devel gcc-c++"
change_name="www"
change_version="2.2.15"

[ -d $down_path ] || {
    mkdir $down_path -p
    action "init download path is" /bin/true
}

download_nginx() {
    cd $down_path
    wget -q $nginx_download_url
    [ $? -eq 0 ] && {
        action "download nginx is" /bin/true
    } || {
        action "download nginx is" /bin/false
        exit 1
    }
}
# download_nginx

install_nginx_relay() {
    yum install -y $nginx_relay &> /dev/null 
    [ $? -eq 0 ] || {
        action "install_nginx_relay is" /bin/false
        exit 2
    }
    action "install_nginx_relay is" /bin/true
}
# install_nginx_relay

add_run_nginx_user() {
     id $nginx_run_user &> /dev/null
     [ $? -eq 0 ] || {
        useradd $nginx_run_user -s /sbin/nologin -M
     }
     action "add_run_nginx_user is" /bin/true  
}
# add_run_nginx_user

untar_nginx() {
    cd $down_path
    tar -xf $nginx_package_name
    [ $? -eq 0 ] || {
        echo "$nginx_package_name not exit"
        action "install nginx is" /bin/false
        exit 3
    }
    action "tar -xf $nginx_package_name is" /bin/true
}

hiden_version() {
    cd $down_path
    cd `echo "$nginx_package_name"|sed "s#.tar.gz##g"`
    sed -i "s/`echo "$nginx_package_name"| sed "s/.tar.gz//g"\
    |sed "s/nginx-//g"`/${change_version}/g" src/core/nginx.h
    sed -i "s/nginx\//${change_name}\//g" src/core/nginx.h
    sed -i "s/\"NGINX\"/\"`echo $change_name|tr '[a-z]' '[A-Z]'`\"/g" src/core/nginx.h
    sed -i "s/Server: nginx/Server: ${change_name}/g" src/http/ngx_http_header_filter_module.c
    sed -i "s/<center>nginx</<center>${change_name}</g" src/http/ngx_http_special_response.c
    action "nginx hiden version is" /bin/true
}
# hiden_version

install_nginx() {
    cd $down_path
    cd `echo "$nginx_package_name"|sed "s/.tar.gz//g"`
    ./configure \
    --user=$nginx_run_user \
    --group=$nginx_run_user \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --prefix=$install_path/`echo "$nginx_package_name"|sed "s#.tar.gz##g"` &> /dev/null
    [ $? -eq 0 ] && {
        action "nginx configure is" /bin/true
    } || {
        action "nginx configure is" /bin/false
        exit 4
    }
    
    make &> /dev/null && {
        action "nginx make  is" /bin/true    
    } || {
        action "nginx make  is" /bin/false
        exit 5
    }

    make install &> /dev/null && {
        action "nginx  make install is" /bin/true
    } || {
        action "nginx  make install is" /bin/true
        eixt 6
    }

    ln -s $install_path/`echo "$nginx_package_name"|sed "s#.tar.gz##g"` $install_path/nginx && {
        action "create softlink is" /bin/true
    } || {
        action "create softlink is" /bin/false
        exit 7
    }
    action "nginx install is" /bin/true
}
# install_nginx

main() {
    download_nginx
    untar_nginx
    hiden_version
    install_nginx_relay
    add_run_nginx_user
    install_nginx
}
main
