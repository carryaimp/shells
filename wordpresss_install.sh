#!/bin/sh\n
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

downloadPath="$HOME/tools"
nginxPath="/application/nginx/"
name="wordpress"
version="4.9.1"
wordPressPkg="${name}-${version}-zh_CN"
wordPressUrl="https://cn.${name}.org/${wordPressPkg}.tar.gz"
installPath="/application/nginx/html/blog"
user="nginx"
nfsServerIP="172.16.1.5"
nfsPkg="nfs-utils rpcbind"
serverNfsPaht="/data/blog"
clientNfsPaht="${installPath}/wp-content/uploads"

. /etc/init.d/functions

function sureOk {
    [ $? -eq 0 ] && {
        action "$2 is " /bin/true
    } || {
        action "$2 is" /bin/false
        exit $?
    }
}

[ -d $downloadPath ] || {
    mkdir -p $downloadPath
    sureOk $? "init downloadPath"
}

function installNfsEnv {
    yum install -y $nfsPkg
    sureOk $? "installNfsEnv"
}

function downloadWordpress {
    cd $downloadPath
    wget -q $wordPressUrl
    sureOk $? "downloadWordpress"
}
# downloadWordpress

function untarWordpress {
    cd $downloadPath
    tar -xf ${wordPressPkg}.tar.gz
    sureOk $? "untarWordpress"
}
# untarWordpress

function installWordpress {
    cd $downloadPath
    [ -d $installPath ] || {
        mkdir -p $installPath
        sureOk $? "init installPath"
    }
    \cp -r $downloadPath/$name/* $installPath/
     sureOk $? "installWordpress"
     chown -R ${user}.${user} $installPath
     sureOk $? "chown $user to $installPath"
}
# installWordpress

function wordpressNfsMount {
    [ -d $clientNfsPaht ] || {
        mkdir -p $clientNfsPaht
        sureOk $? "init wordpressNfsMountDir"
    }
    showmount -e $nfsServerIP &> /dev/null
    sureOk $? "showMounts $nfsServerIP"
    mount -t nfs -o bg,hard,intr,nosuid,noexec,noatime ${nfsServerIP}:${serverNfsPaht} $clientNfsPaht
    sureOk $? "wordpressNfsMount"
    echo "mount -t nfs -o bg,hard,intr,nosuid,noexec,noatime ${nfsServerIP}:${nfsPah}t $serverNfsPaht" >> /etc/rc.local
    sureOk $? "add wordpressNfsMount to rc.local"
}
# wordpressNfsMount

