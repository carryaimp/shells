#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

download_to="$HOME/tools"
py_version="3.6.4"
install_path="/application"
yilai_bao="zlib-devel gcc gcc-c++ openssl-devel sqlite-devel"
env_path="/etc/profile"
add_path="/application/python/bin"
vitrualenv_path="$HOME/.pyenv"
user_env_path="$HOME/.bashrc"

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
    ./configure --enable-optimizations --prefix=${install_path}/Python-${py_version} --with-ssl &> /dev/null
    sure_ok $? "python configure"  
}
# go_configure

go_make() {
    cd $download_to/Python-${py_version}
    echo "may be slow, please wait..."
    make &> /dev/null
    sure_ok $? "python- make"
}
# go_make

go_make_install() {
    cd $download_to/Python-${py_version}
    echo "also need some time, please wait..."
    make install &> /dev/null
    sure_ok $? "python make install"
}
# go_make_install

create_soft_link() {
    ln -s ${install_path}/Python-${py_version} ${install_path}/python
    sure_ok $? "python create soft link"
}
# create_soft_link

go_add_path() {
    linse_num=`sed -n '/export PATH=/=' $env_path`
    [ -z "$linse_num" ] && {
        echo "export PATH=\"$add_path:$PATH\"" >> $env_path
        sure_ok $? "python add path"
    } || {
        change_data=$( echo `sed -n '/export PATH=/p' $env_path`| awk -F '[ "]' -v v=$add_path  '{print $1,$2"\""$2$3":"v"\""}')
        sed -i "${linse_num}c $change_data" $env_path
        . $env_path
        sure_ok $? "python add path"
    }   
}
# go_add_path

go_aliyun_pip(){
    [ -d $HOME/.pip ] || {
        mkdir $HOME/.pip -p
        sure_ok $? "init .pip dir"
    }
    cd $HOME/.pip
    echo -e "[global]\ntrusted-host=mirrors.aliyun.com\nindex-url=http://mirrors.aliyun.com/pypi/simple/" > pip.conf
    sure_ok $? "python go aliyun pip"
}
# go_aliyun_pip

go_install_vitualenv() {
    . $env_path
    pip3 install virtualenvwrapper >> /dev/null
    sure_ok $? "python install virtualenv"
}
# go_install_vitualenv

go_setting_vitualenv() {
    [ -d $vitrualenv_path ] || {
        mkdir $vitrualenv_path -p
        sure_ok $? "python mkdir $vitrualenv_path"
    }
   cat>>$user_env_path<<jia
export VIRTUALENV_USE_DISTRIBUTE=1
export WORKON_HOME=$vitrualenv_path
export VIRTUALENVWRAPPER_PYTHON=$add_path/python3
if [ -e $add_path/virtualenvwrapper.sh ];then
    source $add_path/virtualenvwrapper.sh
fi
export PIP_VIRTUALENV_BASE=\$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
jia
    sure_ok $? "python setting virtualenv"
}
# go_setting_vitualenv

person_virtualenv_alias() {
    sed -i "9i # only want to easy use and read\n\
# you also can set what you like\n\
alias mkenv='mkvirtualenv'\n\
alias rmenv='rmvirtualenv'\n\
alias outenv='deactivate'" $user_env_path
    sure_ok $? "python vituralenv person setting"
}
# person_virtualenv_alais

beimenchuixue_main() {
    install_yilai
    down_python
    jie_ya
    go_configure
    go_make
    go_make_install
    create_soft_link
    go_add_path
    go_aliyun_pip
    go_install_vitualenv
    go_setting_vitualenv
    person_virtualenv_alias
}

beimenchuixue_main

# ^_^
