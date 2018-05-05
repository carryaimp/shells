#!/bin/sh

# author: beimenchuixue
# email: 42283556@qq.com
# blog:Warning: http://www.cnblogs.com/2bjiujiu/

# chkconfig: 2345 98 25

rsyncPid="/var/run/rsyncd.pid"

. /etc/init.d/functions

function sureOK {
    [ $1 -eq 0 ] && {
        action "$2 is"  /bin/true
    } || {
        action "$2 is"  /bin/false
        exit $1
    }
}

[ ${#} -eq 1 ] || {
    echo "$0 (start|stop|restart)"
    exit 1
}

function startRsyncDaemon {
    [ -f $rsyncPid ] && {
        echo "rsync is running"
        sureOK 1 "start rsync"
    }
    rsync --daemon
    sureOK $? "start rsync"
}
# RsyncDaemon

function stopRsyncDaemon {
    if [ ! -f $rsyncPid ]; then
        echo "rsync is stoping"
        sureOK 1 "stop rsync"
    else
        kill $(cat $rsyncPid)
        sleep 1
        if [ -f $rsyncPid ]; then
            kill -9 $(cat $rsyncPid)
            sureOK $? "stop rsync"
        else
            sureOK 0 "stop rsync"
        fi
    fi
}
# stopRsyncDaemon

function restartRsyncDaemon {
    stopRsyncDaemon
    startRsyncDaemon
}

case $1 in
    start)
        startRsyncDaemon
    ;;
    stop)
        stopRsyncDaemon
    ;;
    restart)
        restartRsyncDaemon
    ;;
    *)
        echo "$0 (start|stop|restart)"
        exit 3
esac
