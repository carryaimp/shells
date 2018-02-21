#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

download_to=$HOME'/tools'
py_version='3.6.4'
install_path='/application'
yilai_bao="zlib-devel gcc gcc-c++"
env_path="/etc/profile"
add_path="/application/Python/bin"

. /etc/init.d/functions

sure_ok() {
    [ $1 -eq 0 ] && {
        action "$2 is" /bin/true
    } || {
        action "$2 is" /bin/false
        exit $1
    }
}

install_yilai() {
    yum install -y $yilai_bao
    sure_ok $? "python yilai_bao install"
}
# install_yilai

down_python() {
    [ -d $download_to ] || {
        mkdir $download_to -p
        action "init download path is" /bin/true
    }
    cd $download_to
    yum install -y wget &> /dev/null
    echo "Foreign sities may be slow, please waitting"
    wget -q https://www.python.org/ftp/python/${py_version}/Python-${py_version}.tgz &> /dev/null
    sure_ok $? 'down python-$py_version'
}
# down_python

jie_ya() {
    cd $download_to
    [ -f Python-${py_version}.tgz ] && {
        tar -xf Python-${py_version}.tgz
    } || {
        down_python
        tar -xf Python-${py_version}.tgz
    }
    sure_ok $? "python jie ya"
}
# jie_ya

go_configure() {
    cd $download_to/Python-${py_version}
    ./configure --enable-optimizations --prefix=${install_path}/Python-${py_version} &> /dev/null
    sure_ok $? "python configure"  
}
# go_configure

go_make() {
    cd $download_to/Python-${py_version}
    make
    sure_ok $? "python- make"
}
# go_make

go_make_install() {
    cd $download_to/Python-${py_version}
    make install
    sure_ok $? "python make install"
}
# go_make_install

create_soft_link() {
    ln -s ${install_path}/Python-${py_version} ${install_path}/Python
    sure_ok $? "python create soft link"
}
# create_soft_link

go_add_path() {
    linse_num=`sed -n '/export PATH=/=' $env_path`
    [ -z "$linse_num" ] && {
        echo "export PATH=\"$env_path:$PATH\"" 
        sure_ok $? "python add path"
    } || {
        change_data=$( echo `sed -n '/export PATH=/p' $env_path`| awk -F '[ "]' -v v=$add_path  '{print $1,$2"\""$2$3":"v"\""}')
        sed -i "${linse_num}c $change_data" $env_path
        sure_ok $? "python add path"
    }   
}
go_add_path
