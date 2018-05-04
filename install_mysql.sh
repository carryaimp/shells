#!/bin/sh
# author: beimenchuixue
# blog: http://www.cnblogs.com/2bjiujiu/


downloadPath="$HOME/tools"
version="5.5.60"
pkgPaht="mysql-${version}"
mysqlPkgName="${pkgPaht}.tar.gz"
downloadUrl="https://cdn.mysql.com//Downloads/MySQL-5.5/$mysqlPkgName"
installPaht="/application"
user="mysql"
mysqlRelayPkg="cmake ncurses-devel gcc-c++ openssl-devel"
mysqlRootPwd="123456."
webDatabseName="beimenchuixue"
webDatabasePwd='123456.'
allowIP='172.16.1.%'

. /etc/init.d/functions

function sureOk {
    [ "$1" -eq 0 ] && {
        action "$1 is" /bin/true
    } || {
        action "$1 is" /bin/false
        exit $1
    }
}

# try sure 
[ -d "$downloadPath" ] || {
    mkdir $downloadPath
    sureOk $?
}


function installMysqlRelayPkg {
    yum install -y $mysqlRelayPkg &> /dev/null
    sureOk $? "installMysqlRelayPkg"
}
# installMysqlRelayPkg

function downloadMysql {
    cd $downloadPath
    wget -q $downloadUrl
    sureOk $? "downloadMysql"
}
# downloadMysql

function untarMysql {
    cd $downloadPath
    tar -xf $mysqlPkgName &> /dev/null
    sureOk $? "untarMysql"
}
# untarMysql

function cmakeMysql {
    cd $downloadPath/$pkgPaht
    cmake . \
    -DCMAKE_INSTALL_PREFIX=/application/mysql-$version \
    -DMYSQL_DATADIR=/application/mysql-$version/data \
    -DMYSQL_UNIX_ADDR=/application/mysql-$version/mysql.sock \
    -DEXTRA_CHARSETS=gbk,gb2312,utf8,ascii \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_FEDERATED_STORAGE_ENGINE=1 \
    -DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITHOUT_PARTITION_STORAGE_ENGINE=1 \
    -DWITH_SSL=yes \
    -DENABLED_LOCAL_INFILE=1 \
    -DWITH_ZLIB=bundled \
    -DWITH_READLINE=1 &> /dev/null
    sureOk $? "cmakeMysql"
}
# cmakeMysql

function installMysql {
    cd $downloadPath/$pkgPaht
    make && make install &> /dev/null
    sureOk $? "installMysql"
}
# installMysql

function addMysqlUser {
    id $user &> /dev/null
    [ $? -eq 0 ] && {
        return
    }
    useradd $user -s /sbin/nologin -M
    sureOk $? "addMysqlUser"
}
# addMysqlUser

function createSoftLink {
   cd  $installPaht
   ln -s $pkgPaht mysql
   sureOk $? "createSoftLink"
}
# createSoftLink

function grantMysqlUser {
    cd  $installPaht
    chown -R ${user}.$user mysql/
    sureOk $? "grantMysqlUser"
}
# grantMysqlUser

function initMysql {
    cd $installPaht/mysql/scripts/
    ./mysql_install_db --basedir=$installPaht/mysql --datadir=$installPaht/mysql/data/ --user=mysql &> /dev/null
    sureOk $? "initMysql"

}
# initMysql

function MysqlConf {
    cd $installPaht/mysql/support-files
    \cp mysql.server /etc/init.d/mysqld
    sureOk $? "MysqlConf server"
    \cp my-small.cnf /etc/my.cnf
    sureOk $? "MysqlConf cnf"
}
# MysqlConf

function initMysqlServer {
    chkconfig --add mysqld
    sureOk $? "initMysqlServer chkconfig add"
    chkconfig mysqld on
    sureOk $? "initMysqlServer chkconfig on"
    echo 'export PATH="/application/mysql/bin/:$PATH"' >> /etc/profile
    sureOk $? "add to /etc/profile"
}
# initMysqlServer

function startMysqlServer {
    /etc/init.d/mysqld start &> /dev/null
    sureOk $? "startMysqlServer"
}
# startMysqlServer

function initRootPwd {
    mysqladmin -u root password "$mysqlRootPwd"
    sureOk $? "mysqlRootPwd"
}
# initRootPwd

function initWebMysql {
    dropSql="drop user ''@localhost;drop user ''@'$(hostname)';drop database test;"
    createDatabase="create database $webDatabseName;"
    grantUser="grant all on ${webDatabseName}.* to '${webDatabseName}'@'${allowIP}' identified by '${webDatabasePwd}';"
    flushSql="flush privileges;"
    mysql -uroot -p$mysqlRootPwd -e "$dropSql"
    mysql -uroot -p$mysqlRootPwd -e "$createDatabase"
    mysql -uroot -p$mysqlRootPwd -e "$grantUser"
    mysql -uroot -p$mysqlRootPwd -e "$flushSql"
    sureOk $? "initWebMysql"
}

# initWebMysql


function beiMenChuXueMain {
    installMysqlRelayPkg
    downloadMysql
    untarMysql
    cmakeMysql
    installMysql
    addMysqlUser
    createSoftLink
    grantMysqlUser
    initMysql
    MysqlConf 
    initMysqlServer
    startMysqlServer
    initRootPwd
    initWebMysql
}

beiMenChuXueMain
