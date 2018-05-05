#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

# crontabTask
# echo "00 11 * * * *  /bin/sh $HOME/shells/proxy_backup.sh &> /dev/null" > /var/spool/cron/root

rsyncClientPwdFile="/etc/rsync.password"
rysncClientPwd="123456"
backupPath="/application/nginx/conf /etc/keepalived"
networkDev="eth1"
splitRune="_"
clientRsyncRootPath="/backup"


clientHostName=$(uname -n)
clientIP=$(ip a show dev eth1 | awk -F "[ /]+" 'NR==3{print $3}')
clientDate=$(date +%F)
clientRsyncPath="$clientHostName$splitRune$clientIP$splitRune$clientDate"

serverRsyncUser="beimenchuixue"
serverRsyncIP="10.0.0.4"
serverRsyncModul="backup"

. /etc/init.d/functions

function sureOk {
    [ $1 -eq 0 ] && {
        action "$2 is"  /bin/true    
    } || {
        action "$2 is"  /bin/false
        exit $1
    }
}


[ -d $clientRsyncRootPath ] || {
    mkdir $clientRsyncRootPath
}

function setRsyncClientPwd {
    [ -f $rysncClientPwd ] || {
        echo $rysncClientPwd > $rsyncClientPwdFile
        chmod 000 $rsyncClientPwdFile
        sureOk $? "setRsyncClinetPwd"
    }
}
# setRsyncClientPwd

function initRsyncDir {
    cd $clientRsyncRootPath
    [ -d $clientRsyncPath ] || {
        mkdir -p $clientRsyncPath
        sureOk $? "initRsyncDir"
    }
}
# initRsyncDir

function copyBackupPath {
    cd $clientRsyncRootPath/$clientRsyncPath
    sureOk $? "cd targetPath"
    for path in $backupPath
    do
        \cp -r $path .
    done
    sureOk $? "copyBackupPath"
}
# copyBackupPath

function ToRsync {
    rsync -avz $clientRsyncRootPath/$clientRsyncPath $serverRsyncUser@$serverRsyncIP::$serverRsyncModul/ --password-file=$rsyncClientPwdFile &> /dev/null
    sureOk $? "ToRsync"
}
# ToRsync

function save2DayFile {
    find $clientRsyncRootPath -type d -mtime +2 | xargs rm -rf
    sureOk $? "save2DayFile"
}
# save2DayFile

function main_BeiMenChuiXue {
    setRsyncClientPwd   
    initRsyncDir
    copyBackupPath
    ToRsync
    save2DayFile
}
main_BeiMenChuiXue

