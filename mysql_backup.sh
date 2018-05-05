#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

# crontabTask
# echo "00 11 * * * *  /bin/sh $HOME/shells/mysql_backup.sh &> /dev/null" > /var/spool/cron/root

rsyncClientPwdFile="/etc/rsync.password"
rysncClientPwd="123456"
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

mysqlUser="root"
mysqlPwd="123456."
mysqldumpOption="-A -B --single-transaction --events"

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

function mysqldumpSql {
    [ -L /usr/bin/mysqldump ] || {
        ln -s /application/mysql/bin/mysqldump /usr/bin/mysqldump
        sureOk $? "init mysqldump softLink"
    }
    mysqldump -u$mysqlUser -p$mysqlPwd $mysqldumpOption |gzip > $clientRsyncRootPath/$clientRsyncPath/mysql_$(date +%F).sql.gz &> /dev/null
    sureOk $? "mysqldumpSql"
}
# mysqldumpSql

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
    mysqldumpSql
    ToRsync
    save2DayFile
}
main_BeiMenChuiXue

