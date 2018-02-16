#!/bin/sh

# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

. /etc/init.d/functions

login_password="123456"
login_user="beimenchuixue"
model="workspace"
samba_conf_file="/etc/samba/smb.conf"

install_samb() {
    yum install -y samba &> /dev/null
    [ $? -eq 0 ] && {
        action "samb server install is" /bin/true
    } || {
        action "samb server install is" /bin/false
        exit 1
    }
}
# install_samb

add_samba_user() {
    id $login_user &> /dev/null
    [ $? -eq 0 ] || {
        useradd $login_user -s /sbin/nologin
    }
    action "samba_user is" /bin/true
}
# add_samba_user

install_expect() {
    yum install -y expect &> /dev/null
    [ $? -eq 0 ] || {
        action "install_expect is" /bin/false
        exit 2
    }
    action "install_expect is" /bin/true
}
# install_expect

set_user_pwd() {
    `which expect` <<jia
    set timeout -1

    spawn smbpasswd -a $login_user
    expect {
        "*password:" {send "${login_password}\r";exp_continue}
    }
jia
    [ $? -eq 0 ] && {
        action "set password is" /bin/true
    } || {
        action "set password is" /bin/false
        exit 3
    }
}
# set_user_pwd

init_start_smb() {
    /etc/init.d/smb restart &> /dev/null
    chkconfig smb on
    action "start smb is" /bin/true
}
# init_start_smb

main() {
    install_samb
    add_samba_user
    install_expect
    set_user_pwd
    init_start_smb
}
main
