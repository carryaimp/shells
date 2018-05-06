#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

masterIP="172.16.1.120"

aliRepoOs6="https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el6.noarch.rpm"
aliRepoOs7Py2="https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm"
aliRepoOs7Py3="https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest-2.el7.noarch.rpm"

osVersion=$(awk -F "[ .]+" '{print $4}' /etc/redhat-release)

masterTool="salt-maste"
minionTool="salt-minion"

saltstackRepoConf="/etc/yum.repos.d/salt-latest.repo"
minionConf="/etc/salt/minion"

[ ${#} -eq 1 ] || {
    echo "$0  (master|minion)"
    exit 1
}

. /etc/init.d/functions

function sureOk {
    [ $1 -eq 0 ] && {
        action "$2 is"  /bin/true
    } || {
        action "$2 is"  /bin/false
        exit $1
    }
}

function aliRepoInstall {
    [ -f $saltstackRepoConf ] && {
        sureOk 0 "aliRepoInstall"
        return
    }
    if [ $osVersion -eq 7 ]; then
        yum install -y  $aliRepoOs7Py3  &> /dev/null
        sureOk $? "saltstack repo"
        sed -i "s/repo.saltstack.com/mirrors.aliyun.com\/saltstack/g" $saltstackRepoConf
        sureOk $? "aliRepoInstall"
    else
        yum install -y $aliRepoOs6  &> /dev/null
        sureOk $? "saltstack repo"
        sed -i "s/repo.saltstack.com/mirrors.aliyun.com\/saltstack/g" $saltstackRepoConf
        sureOk $? "aliRepoInstall"
    fi
}
# aliRepoInstall

function masterInstall {
    yum install -y $masterTool $minionTool &> /dev/null
    sureOk $? "masterInstall"
}
# masterInstall

function minionInstall {
    yum install -y $minionTool &> /dev/null
    sureOk $? "minionInstall"
}
# minionInstall

function startMaster {
    if [ $osVersion -eq 7 ]; then
        systemctl start salt-master &> /dev/null
        sureOk $? "startMaster"
    else
        /etc/init.d/salt-master start &> /dev/null
        sureOk $? "startMaster"
    fi
}

function MinionConf {
    sed -i "s/#master: salt/master: $masterIP/g" $minionConf
    sureOk $? "MinionConf"
}

function startMinion {
    if [ $osVersion -eq 7 ]; then
        systemctl start salt-minion &> /dev/null
        sureOk $? "startMaster"
    else
        /etc/init.d/salt-minion start &> /dev/null
        sureOk $? "startMaster"
    fi
}

case $1 in
    master)
    aliRepoInstall
    masterInstall
    startMaster
    ;;
    minion)
    aliRepoInstall
    minionInstall
    MinionConf
    startMinion
    ;;
    *)
    echo "$0  (master|minion)"
    exit 1
esac
