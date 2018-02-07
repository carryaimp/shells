#!/bin/sh

# author: beimenchuixue
# email: 42283556@qq.com
# blog:Warning: http://www.cnblogs.com/2bjiujiu/

# chkconfig: 2345 98 25
# description: rsync daemon chkconfig manage

. /etc/init.d/functions

conf_path="/etc/rsyncd.conf"
rsync_pid="/var/run/rsyncd.pid"
backup_path="/backup"
daemon_pwd_file="/etc/rsync.password"
user="rsync"
login_user="rsync_backup"
login_password="beimenchuixue"

# init rsync daemon conf
[ -f $conf_path ] || {
    cat >>$conf_path<<jia
uid = $user
gid = $user
use chroot = no
max connections = 200
timeout = 300
pid file = $rsync_pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
ignore errors
read only = false
list = false
# host allow = 172.16.1.0/24
# host deny = 0.0.0.0/32
auth users = $login_user
secrets file = $daemon_pwd_file
[backup]
path = $backup_path
jia
  action "init rsync conf is" /bin/true  
}

start_rsyncd() {
    [ -f $rsync_pid ] && {
        echo "rsync is running"
        action "start rsync is" /bin/false
        exit 2
    }
    id $user &> /dev/null
    [ $? -eq 0 ] || {
        useradd $user -s /sbin/nologin -M
    }
    [ -d $backup_path ] || {
        mkdir -p $backup_path
    }
    chown -R ${user}.${user} $backup_path
    rsync --daemon
    [ $? -eq 0 ] && {
        action "start rsync is" /bin/true
    }
}

stop_rsyncd() {
    [ -f $rsync_pid ] || {
        echo "rsync is stoping"
        action "stop rsync is" /bin/false
        exit 1
    }
    kill `cat $rsync_pid`
    sleep 1
    action "stop rsync is" /bin/true
}

restart_rsyncd() {
    stop_rsyncd
    start_rsyncd
}

# insure one param get
[ ${#} -eq 1 ] || {
    echo "$0 (start|stop|restart)"
    exit 3
}

# init password file
[ -f $daemon_pwd_file ] || {
    echo "${login_user}:${login_password}" >> $daemon_pwd_file
    chmod 600 $daemon_pwd_file
    action "init password is" /bin/true
}

case $1 in
    start)
        start_rsyncd
    ;;
    stop)
        stop_rsyncd
    ;;
    restart)
        restart_rsyncd
    ;;
    *)
        echo "$0 (start|stop|restart)"
        exit 3
esac
