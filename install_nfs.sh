#!/bin/sh\n
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

nfsRelayPkg="nfs-utils rpcbind"
nfsUser="nginx"
allowIP="127.16.1.0/24"
nfsConfPath="/etc/exports"
nfsDataPath="/data"
KernerVersion="$(uname -r | awk -F "[.]" '{print $1}')"

. /etc/init.d/functions

function sureOk {
    [ "$1" -eq 0 ] && {
        action "$2 is" /bin/true
     } || {
         action "$2 is" /bin/false
         exit $1
     }                                      
}

function initNfsDataPath {
    [ -d $nfsDataPath ] || {
        mkdir -p $nfsDataPath
    }   
    chown -R ${nfsUser}.${nfsUser} $nfsDataPath
    sureOk $? "initNfsDataPath"
}
# initNfsDataPath

function installNfsRelayPkg {
    yum install -y $nfsRelayPkg &> /dev/null
    sureOk $? "installNfsRelayPkg"
}
# installNfsRelayPkg

function AddNfsUser {
    id $nfsUser &> /dev/null
    [ $? -eq 0 ] || {
        useradd $nfsUser -s /sbin/nologin -M
    }
    sureOk $? "AddNfsUser:$nfsUser"
}
# AddNfsUser

function nfsConf {
    echo "/data $allowIP(rw,sync,all_squash,anonuid=$(id -u $nfsUser),anongid=$(id -g $nfsUser))" > $nfsConfPath
    sureOk $? "nfsConf"
}
# nfsConf
function startRpcbind {
    if [ "$KernerVersion" -eq 2 ]; then
        /etc/init.d/rpcbind start
        sureOk $? "starRpcbind"
        chkconfig rpcbind on
        sureOk $? "chkconfig rpcbind on"
    else
        systemctl start rpcbind
        sureOk $? "starRpcbind"
        systemctl enable rpcbind &> /dev/null
        sureOk $? "systemctl enable rpcbind"
    fi
}
# startRpcbind

function startNfs {
    if [ "$KernerVersion" -eq 2 ]; then
        /etc/init.d/nfs start
        sureOk $? "startNfs"
        chkconfig nfs on &> /dev/null
        sureOk $? "chkconfig nfs on"
    else
        systemctl start nfs
        sureOk $? "starNfs"
        systemctl enable nfs &> /dev/null
        sureOk $? "systemctl enable nfs"
    fi
}
# startNfs

function nfsTest {
    localIP=$(ip a show dev eth0|awk -F "[ /]+" 'NR==3{print $3}')
    showmount -e $localIP &> /dev/null
    sureOk $? "pass nfsTest"
}
# nfsTest

function main_beiMenChuiXue {
    AddNfsUser
    initNfsDataPath
    installNfsRelayPkg
    nfsConf
    startRpcbind
    startNfs
    nfsTest
}
main_beiMenChuiXue
