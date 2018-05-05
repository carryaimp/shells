#!/bin/sh

# author: beimenchuixue
# email: 42283556@qq.com
# blog:Warning: http://www.cnblogs.com/2bjiujiu/

rsyncConf="/etc/rsyncd.conf"
rsyncPid="/var/run/rsyncd.pid"
rsyncPath="/backup"
ServerPwdFile="/etc/rsync.password"
rsyncUser="rsync"
loginUser="beimenchuixue"
loginPwd="123456"

. /etc/init.d/functions

function sureOK {
    [ $? -eq 0 ] && {
        action "$2 is"  /bin/true
    } || {
        action "$2 is"  /bin/false
        exit $?
    }
}

function hasInstallRsync {
    rsync --version &> /dev/null
    sureOK $? "hasInstallRsync"
}
# hasInstallRsync

function rsyncConf {
    [ -f $rsyncConf ] && {
        cat /dev/null > $rsyncConf
        sureOK $? "init rsyncConf"
    }
    cat >>$rsyncConf<<EOF
uid = $rsyncUser
gid = $rsyncUser
use chroot = no
max connections = 200
timeout = 300
pid file = $rsyncPid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
ignore errors
read only = false
list = false
# host allow = 172.16.1.0/24
# host deny=0.0.0.0/32
auth users = $loginUser
secrets file = $ServerPwdFile

[backup]
path = $rsyncPath
EOF
    sureOK $? "rsyncConf"
}
# rsyncConf

function addRsyncUser {
    id $rsyncUser &> /dev/null
    [ $? -eq 0 ] || {
        useradd $rsyncUser -s /sbin/nologin -M
    }
    sureOK $? "addRsyncUser"
}
# addRsyncUser

function initRsyncPath {
    [ -d $rsyncPath ] || {
        mkdir -p $rsyncPath
        sureOK $? "create $rsyncPath"
    }
    chown -R ${rsyncUser}.${rsyncUser} $rsyncPath
    sureOK $? "initRsyncPath"
}
# initRsyncPath

function initServerRsyncPwdFile {
    [ -f $ServerPwdFile ] && {
        cat /dev/null > $ServerPwdFile
        sureOK $? "clear ServerRsyncPwdFile"
    }
    echo "$loginUser:$loginPwd" > $ServerPwdFile
    sureOK $? "write rsyncPwd"
    chmod 000 $ServerPwdFile
}
# initServerRsyncPwdFile

function main_BeiMenChuiXue {
    hasInstallRsync
    rsyncConf
    addRsyncUser
    initRsyncPath
    initServerRsyncPwdFile
}
main_BeiMenChuiXue
