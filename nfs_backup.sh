#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

# crontabTask
# echo "00 11 * * * *  /bin/sh $HOME/shells/nfs_backup.sh &> /dev/null" > /var/spool/cron/root

rsyncClientPwdFile="/etc/rsync.password"
rysncClientPwd="123456"

serverRsyncUser="beimenchuixue"
serverRsyncIP="10.0.0.4"
serverRsyncModul="backup"

toolsName="inotify-tools"
mointorPath="/data/blog"


. /etc/init.d/functions

function sureOk {
    [ $1 -eq 0 ] && {
        action "$2 is"  /bin/true    
    } || {
        action "$2 is"  /bin/false
        exit $1
    }
}

[ -d $mointorPath ] || {
    sureOk 1 "$mointorPath not exist"
}

function initClientPwdFile {
    [ -f $rsyncClientPwdFile ] || {
        echo $rysncClientPwd > $rsyncClientPwdFile
        chmod 000 $rsyncClientPwdFile
    }
    sureOk $? "initClientPwdFile"
}

function toolsInstall {
    yum install -y $toolsName &> /dev/null
    sureOk $? "$toolsName install"
}
# toolsInstall

function createMointor {
    rsync -avz $mointorPath --delete $serverRsyncUser@$serverRsyncIP::$serverRsyncModul/ --password-file=$rsyncClientPwdFile &> /dev/null
    sureOk $? "nfsPath backup"
    inotifywait -mrq --format '%w%f' -e close_write,delete $mointorPath|while read file
    do
        rsync -avz $mointorPath --delete $serverRsyncUser@$serverRsyncIP::$serverRsyncModul/ --password-file=$rsyncClientPwdFile &> /dev/null
        sureOk $? "backup target file $file"
    done
}
# createMointor

function main_BeiMenChuiXue {
    initClientPwdFile
    toolsInstall
    createMointor
}
main_BeiMenChuiXue
