#!/bin/sh\n
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

KernerVersion="$(uname -r | awk -F "[.]" '{print $1}')"
localIP=$(ip a show dev eth0 | awk -F "[ /]+" 'NR==3{print $3}')
keepalivedConf="/etc/keepalived/keepalived.conf"
email="422083556@qq.com"
# BACKUP
serverType="MASTER"
# LVS_DEVE
idName="LVS_DEVEL "
netDev="eth0"
vRouterId="51"
VIP="10.0.0.11/24"


. /etc/init.d/functions

function sureOk {
    [ "$1" -eq 0 ] && {
        action "$2 is" /bin/true
    } || {
        action "$2 is" /bin/false
        exit $1
    }
}

function yumInstallKeepalived {
    yum install -y keepalived &> /dev/null
    sureOk $? "yumInstallKeepalived"
}
# yumInstallKeepalived

function toKeepalivedConf {
	cat /dev/null > $keepalivedConf
	sureOk $? "init keepalivedConf"
	cat >> $keepalivedConf<<EOF
! Configuration File for keepalived
global_defs {
   notification_email {
		$email                                 
	}
   notification_email_from $email           
   smtp_server $localIP
   smtp_connect_timeout 30
   router_id $idName
}
 
vrrp_instance VI_1 {
    state $serverType
    interface $netDev
    virtual_router_id $vRouterId
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    } 
 
    virtual_ipaddress {
        $VIP
    } 
}
EOF
	sureOk $? "toKeepalivedConf"
}
# toKeepalivedConf

function startKeepalvie {
	if [ "$KernerVersion" -eq 2 ]; then
        /etc/init.d/keepalived start	&> /dev/null
        sureOk $? "startKeepalvie"
        chkconfig keepalived on &> /dev/null
        sureOk $? "chkconfig keepalived on"
    else
        systemctl start keepalived &> /dev/null
        sureOk $? "startKeepalvie"
        systemctl enable keepalived &> /dev/null
        sureOk $? "systemctl keepalived rpcbind"
    fi
}
# startKeepalvie

function main_BeiMenChuiXue {
	yumInstallKeepalived
	toKeepalivedConf
	startKeepalvie 
}
main_BeiMenChuiXue
