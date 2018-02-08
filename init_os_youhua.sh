#!/bin/sh
# author: beimenchuixue
# blog: http://www.cnblogs.com/2bjiujiu/`

# use cron + ntp update time
. /etc/init.d/functions
update_time() {
    echo -e "# update time\n*/5 * * * * /usr/sbin/ntpdate time1.aliyun.com &> /dev/null" >> /var/spool/cron/$(whoami)
    action "cron+ntp get time is" /bin/true
}

# update_time

# change yum and epel
aliyun_epel_yum() {
    centos_version=$(awk -F '[. ]' '{print $3}' /etc/redhat-release)
    [ -f /etc/yum.repos.d/CentOS-Base.repo ] && {
        # intall yum_repo and backup old repo
        /bin/mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.$(date +%F)
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-${centos_version}.repo &> /dev/null
        # install epel
        [ $? -eq 0 ] && {
            # if install
            [ $(rpm -qa | grep epel |wc -l) -eq 1 ] && {
            rpm -e $(rpm -qa | grep epel)
            }
            rpm -ivh https://mirrors.aliyun.com/epel/epel-release-latest-${centos_version}.noarch.rpm &> /dev/null
            action "yum epel aliyun is" /bin/true
        } || {
            /bin/mv /etc/yum.repos.d/CentOS-Base.repo.$(date +%F) /etc/yum.repos.d/CentOS-Base.repo    
            action "yum epel aliyun is" /bin/false
        }
    }

}
# aliyun_epel_yum

# stop selinux
stop_selinx() {
  sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
  setenforce 0
  action "stop selinux is" /bin/true
}
# stop_selinx

stop_iptable() {
    /etc/init.d/iptables stop &> /dev/null
    chkconfig iptables off
    action "stop iptables is" /bin/true
}
# stop_iptable

# hide os version
hide_version() {
  > /etc/issue
  > /etc/issue.net
  action "hide version is" /bin/true
}
# hide_version

# in order to let clone host connect internet
clone_connect_internet() {
    sed -i -r "/HWADDR|UUID/d" /etc/sysconfig/network-scripts/ifcfg-eth0
    [ -f /etc/sysconfig/network-scripts/ifcfg-eth1 ] && {
        sed -i -r "/HWADDR|UUID/d" /etc/sysconfig/network-scripts/ifcfg-eth1
    }
    >/etc/udev/rules.d/70-persistent-net.rules
    echo ">/etc/udev/rules.d/70-persistent-net.rules" >> /etc/rc.local
    ifdown eth0 && ifup eth0 &> /dev/null
    action "clone_vm connection internet setting is" /bin/true
}
# clone_connect_internet

# only 5 server need onboot
start_need_server() {
    chkconfig --list|grep "3:on"|egrep -v 'sshd|sysstat|crond|network|rsyslog'|awk '{print "chkconfig",$1,"off"}'|bash
    action "(sshd sysstat crond network rsyslog) onboot is" /bin/true
}
# start_need_server

# incrase file descriptior
increase_file_desc() {
    echo " *               -       nofile            65535 " >> /etc/security/limits.conf
    action "incrase file descriptior is" /bin/true    
}
# increase_file_desc

init_os_main() {
    update_time
    stop_iptable
    stop_selinx
    hide_version
    clone_connect_internet
    start_need_server
    aliyun_epel_yum
    increase_file_desc        
}
init_os_main
