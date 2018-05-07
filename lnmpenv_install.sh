#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

# install LNMP env 
# 这些安装方式只适于下面指定版本的软件安装，其他版本没有测试，谨慎
# 可能需要 dos2nuix 工具对该文件进行转换

[ ${#} -eq 0 ] || {
    echo "$0 need 0 parameter but you give ${#}"
    exit 1
}

. /etc/init.d/functions

function sureOk {
    [ $1 -eq 0 ] && {
        action "$2 is" /bin/true
    } || {
        action "$2 is" /bin/false
        exit $1
    }
}

# 获取系统版本
[ $(awk -F "[ .]+" '{print $3}' /etc/redhat-release) == "6" ] && {
    CentosVersion="6"
} || {
    CentosVersion="7"
}

# 开机启动加载文件
onbootFile="/etc/rc.local"

# 全局变量
globalPath="/etc/profile"

# 全局下载位置
soureDownloadPath="$HOME/tools"

# 全局安装目录
installPath="/application"

# mysql php nginx 相关依赖
mysqlRelayPkg="cmake,ncurses-devel,gcc-c++,openssl-devel"
nginxRelayPkg="pcre-devel,openssl-devel,gcc-c++"
phpRelayPkg="zlib-devel,libxml2-devel,libjpeg-devel,\
libjpeg-turbo-devel,libiconv-devel,freetype-devel,\
libpng-devel,gd-devel,libcurl-devel,libxslt-devel,\
libmcrypt-devel,mhash,mcrypt,openssl-devel,gcc,gcc++"

# 软件名字
mysqlSoftName="mysql"

nginxSoftName="nginx"
nginxServerName="www"

phpLibiconvSoftName="libiconv"
phpSoftName="php"

# 软件版本信息
mysqlVersion="5.5.60"
nginxVersion="1.12.2"
nginxHidenVersion="2.2.15"
phpLibiconvVersion="1.14"
phpVersion="7.0.0"

# 软件执行文件目录
mysqlBinPaht="bin"
nginxBinPath="sbin"
FastCGIBinPath="sbin"

# 软件启动命令
nginxStartCmd="nginx"
FastCGIStartCmd="php-fpm"

# 软件解压后文件名
mysqlPkgPath="${mysqlSoftName}-${mysqlVersion}"
nginxPkgPath="${nginxSoftName}-${nginxVersion}"
phpLibiconvPkgPath="${phpLibiconvSoftName}-${phpLibiconvVersion}"
phpPkgPath="${phpSoftName}-${phpVersion}"

# 软件下载压缩包名
mysqlPkgName="${mysqlPkgPath}.tar.gz"
nginxPkgName="${nginxPkgPath}.tar.gz"
phpLibiconvPkgName="${phpLibiconvPkgPath}.tar.gz"
phpPkgName="${phpPkgPath}.tar.gz"

# 软件核心配置文件
phpConfFile="$installPath/$phpSoftName/lib/php.ini"
nginxConfFile="${installPath}/${nginxSoftName}/conf/nginx.conf"

# 软件下载URL链接
mysqlDownloadUrl="https://cdn.mysql.com//Downloads/MySQL-5.5/$mysqlPkgName"
nginxDownLoadUrl="http://nginx.org/download/${nginxPkgName}"
phpDownLoadUrl="http://mirrors.sohu.com/php/${phpPkgName}"
phpExtraRelayDownLoadUrl="http://down1.chinaunix.net/distfiles/${phpLibiconvPkgName}"
phpLibiconvInstallPaht="/usr/local/${phpLibiconvSoftName}"

# 软件运行态需要的用户
rootUser="root"
mysqlRunUser="mysql"
nginxRunUser="nginx"

# 软件root密码
mysqlRootPwd="123456."

# 软件相关编译参数，通过 : 连接这些参数，然后通过 tr去除这些连接符。 \表示另起一行
mysqlConfigure="\
-DCMAKE_INSTALL_PREFIX=/application/mysql-${mysqlVersion}:\
-DMYSQL_DATADIR=/application/mysql-${mysqlVersion}/data:\
-DMYSQL_UNIX_ADDR=/application/mysql-${mysqlVersion}/mysql.sock:\
-DEXTRA_CHARSETS=gbk,gb2312,utf8,ascii:\
-DWITH_INNOBASE_STORAGE_ENGINE=1:\
-DWITH_FEDERATED_STORAGE_ENGINE=1:\
-DWITHOUT_EXAMPLE_STORAGE_ENGINE=1:\
-DWITH_BLACKHOLE_STORAGE_ENGINE=1:\
-DWITHOUT_PARTITION_STORAGE_ENGINE=1:\
-DWITH_SSL=yes:\
-DENABLED_LOCAL_INFILE=1:\
-DWITH_ZLIB=bundled:\
-DWITH_READLINE=1"

nginxConfigure="\
--user=${nginxRunUser}:\
--group=${nginxRunUser}:\
--with-http_ssl_module:\
--with-http_stub_status_module:\
--prefix=$installPath/$nginxPkgPath"

phpConfigure="\
--prefix=$installPath/$phpPkgPath:\
--with-mysqli=mysqlnd:\
--with-pdo-mysql=mysqlnd:\
--with-iconv-dir=$phpLibiconvInstallPaht:\
--with-freetype-dir:\
--with-jpeg-dir:\
--with-png-dir:\
--with-zlib:\
--with-libxml-dir=/usr:\
--enable-xml:\
--disable-rpath:\
--enable-bcmath:\
--enable-shmop:\
--enable-sysvsem:\
--with-curl:\
--enable-mbregex:\
--enable-fpm:\
--enable-mbstring:\
--with-gd:\
--enable-gd-native-ttf:\
--with-openssl:\
--with-mhash:\
--enable-mcrypt:\
--enable-pcntl:\
--enable-sockets:\
--with-xmlrpc:\
--enable-soap:\
--enable-short-tags:\
--enable-static:\
--with-xsl:\
--with-fpm-user=nginx:\
--with-fpm-group=nginx:\
--enable-ftp:\
--disable-opcache"

phpLibiconvConfigure="--prefix=$phpLibiconvInstallPaht"

# mysql相关信息
mysqlDataPath="${installPath}/$mysqlSoftName/data"
mysqlConfPath="/etc/my.cnf"
mysqlDaemon="/etc/init.d/mysqld"
mysqlSourceDaemonFile="mysql.server"
mysqlSourceConfFile="my-small.cnf"


# 初始化下载目录
[ -d $soureDownloadPath ] || {
    mkdir $soureDownloadPat
    sureOk $? "init DownloadPath"
}

# 第一行说明函数功能，第二行需要传递的参数，env开头为环境函数，契过程封装

# 安装对应软件依赖包
# SoftName RelayPkg
function GoYumRelayPkg {
    echo "yum install $1 RelayPkg ...ing"
    yum install -y $(echo $2|tr ":" " ") &> /dev/null
    sureOk $? "yum install $1 RelayPkg"
}

function envYumRelayPkg {
    GoYumRelayPkg $nginxSoftName $nginxRelayPkg
    GoYumRelayPkg $phpSoftName $phpRelayPkg
}

# 添加软件运行态用户
# RunUser
function GoAddRunUser {
    id $1 &> /dev/null
    [ $? -eq 0 ] || {
        useradd $1 -s /sbin/nologin -M
    }
    sureOk $? "Add User $1"
}

function envAddRunUser {
    GoAddRunUser $nginxRunUser
}

# 下载软件的源码包
# DownloadUrl PkgName
function GoDownload {
    cd $soureDownloadPath
    if [ ! -f $2 ]; then
        echo "download $2 ...ing, please wait ...ing"
        wget -q $1
    fi
    sureOk $? "download $2"    
}

function envPkgDownload {
    GoDownload $nginxDownLoadUrl $nginxSoftName
    GoDownload $phpExtraRelayDownLoadUrl $phpLibiconvSoftName
    GoDownload $phpDownLoadUrl $phpSoftName
}

# 解压软件源码包
# PkgName
function GoUntar {
    cd $soureDownloadPath
    echo "Untar $1 ...ing"
    tar -xf $1
    sureOk $? "Untar $1"    
}

function envUntarPkg {
    GoUntar $nginxPkgName
    GoUntar $phpLibiconvPkgName
    GoUntar $phpPkgName
}

# 设置编译参数
# PkgPath Configure SoftName "make/cmake"
function GoConfigure {
    cd $soureDownloadPath/$1
    if [ $4 == "cmake" ]; then
        echo "cmake $3 ...ing, please wait ...ing"
        cmake $(echo $2|tr ":" " ") &> /dev/null
        sureOk $? "cmake $3"
    else
        # libiconv make时候会出现一个 leaving srclib错误，下面的操作是为了解决这个错误
        [ $3 == $phpLibiconvSoftName ] && {
        cd srclib/
        sed -ir -e "/gets is a security/d" ./stdio.in.h
        sureOk $? "handle $3 error"
        }
        echo "configure $3 ...ing, please wait ...ing"
        ./configure $(echo $2|tr ":" " ") &> /dev/null
        sureOk $? "configure $3"
    fi
}

function envConfigure {
    GoConfigure $nginxPkgPath $nginxConfigure $nginxSoftName "make"
    GoConfigure $phpLibiconvPkgPath $phpLibiconvConfigure $phpLibiconvSoftName "make"
    GoConfigure $phpPkgPath $phpConfigure $phpSoftName "make"
}

# 编译源码
# PkgPath SoftName
function GoMake {
    cd $soureDownloadPath/$1
    echo "Make $2 ...ing, manybe need a long time, please wait ...ing"
    make &> /dev/null
    sureOk $? "make $2"
}

function envMake {
    GoMake $nginxPkgPath $nginxSoftName
    GoMake $phpLibiconvPkgPath $phpLibiconvSoftName
    GoMake $phpPkgPath $phpSoftName
}

# 安装软件
# PkgPath SoftName
function GoMakeInstall {
    cd $soureDownloadPath/$1
    echo "make install $2 ...ing"
    make install &> /dev/null
    sureOk $? "make install $2"
}

function envMakeInstall {
    GoMakeInstall $nginxPkgPath $nginxSoftName
    GoMakeInstall $phpLibiconvPkgPath $phpLibiconvSoftName
    GoMakeInstall $phpPkgPath $phpSoftName
}

# 创建软件对应的软链接
# PkgPath SoftName
function GoCreateSoftLink {
    ln -s $installPath/$1 $installPath/$2
    sureOk $? "CreateSoftLink $2"
}

function envCreateSoftLink {
    GoCreateSoftLink $nginxPkgPath $nginxSoftName
    GoCreateSoftLink $phpPkgPath $phpSoftName
}

# 软件全局变量配置
# nginxSoftName nginxBinPath
function GoGlobalSet {
    # 获取 export所在行
    exportLineNum=`sed -n '/export PATH=/=' $globalPath`
    # 判断 是否存在 export
    if [ -z "$exportLineNum" ]; then
        # 不存在直接追加
        echo "export PATH=\"$installPath/$1/$2:\$PATH\"" >> $globalPath
        sureOk $? "GoGlobalSet $1"
    else
        # 存在则通过sed找到对应的行，然后通过awk进行分割然后再进行拼接，通过 -v 参数接收一个额外字符
        middlePath=$(echo `sed -n '/export PATH=/p' $globalPath`| awk -F '[ "]' -v v=$installPath/$1/$2  '{print $1,$2"\""$2$3":"v"\""}')
        # 通过 sed 替换掉指定的export行
        sed -i "#exportLineNum s/.*/$middlePath/g" $globalPath
        sureOk $? "GoGlobalSet $1"
    fi  
}

function envGlobalSet {
    GoGlobalSet $nginxSoftName $nginxBinPath
    GoGlobalSet $phpSoftName $FastCGIBinPath 
}

# 把软件启动脚本路径添加到环境变量
# SoftName BinPath StartCmd
function GoOnboot {
    echo "$installPath/$1/$2/$3" >> $onbootFile
    if [ $1 == $phpSoftName ]; then
        sureOk 0 "GoOnboot FastCGI"
    else
        sureOk 0 "GoOnboot $1"
    fi
}

function envOnboot {
    GoOnboot $nginxSoftName $nginxBinPath $nginxStartCmd
    GoOnboot $phpSoftName $FastCGIBinPath $FastCGIStartCmd  
}

# 启动软件
# SoftName BinPath StartCmd 
function GoStart {
    if [ $1 == $mysqlSoftName ]; then 
        $installPath/$1/$2/$3 start &> /dev/null
        sureOk $? "Start $1"
    else
        [ $1 == $phpSoftName ] && {
            $installPath/$1/$2/$3
            sureOk $? "Start FastCGI"
        } || {
            $installPath/$1/$2/$3
            sureOk $? "Start $1"
        }  
    fi
}

function envStart {
    GoStart $nginxSoftName $nginxBinPath $nginxStartCmd
    GoStart $phpSoftName $FastCGIBinPath $FastCGIStartCmd
}

# 初始化数据库
# mysqlSoftName mysqlDataPath mysqlRunUser
function initMysql {
    cd $installPath/$1/scripts/
    ./mysql_install_db --basedir=$installPath/$1 --datadir=$2 --user=$3 &> /dev/null
    sureOk $? "initMysql"
}

# 数据库配置初始化
# 
function confMysql {
    cd $installPath/$mysqlSoftName/support-files
    # 拷贝mysql启动程序
    \cp $mysqlSourceDaemonFile $mysqlDaemon
    sureOk $? "Copy mysqlDaemon to /etc/init.d/"
    # 拷贝其配置文件
    \cp $mysqlSourceConfFile $mysqlConfPath
    sureOk $? "Copy mysqlDaemon to /etc/init.d/"
    
    chown -R $mysqlRunUser.$mysqlRunUser $installPath/$mysqlSoftName/
    sureOk $? "init $mysqlRunUser manage $installPath/$mysqlSoftName/"
}

# 初始化数据库root密码
# rootUser mysqlRootPwd
function initMysqlRootPwd {
    . $globalPath
    mysqladmin -u $1 password "$2"
    sureOk $? "initMysqlRootPwd"
}

# 初始化数据库环境，删除无用用户和test数据库
# rootUser mysqlRootPwd
function initMysqlEnv {
    . $globalPath
    dropSql="drop user ''@localhost;drop user ''@'$(hostname)';drop database test;"
    flushSql="flush privileges;"
    mysql -u$1 -p$2 -e "$dropSql" && mysql -u$rootUser -p$mysqlRootPwd -e "$flushSql"
    sureOk $? "initWebMysql"
}

# 启动数据库
function startMysql {
    . /etc/profile
    /etc/init.d/mysqld start &> /dev/null
    sureOk $? "startMysql"
}

# 数据库额外除安装完成之后的一些工作
function envMysqlExtraWork {
    initMysql $mysqlSoftName $mysqlDataPath $mysqlRunUser
    confMysql 
    startMysql
    initMysqlRootPwd $rootUser $mysqlRootPwd
    initMysqlEnv $rootUser $mysqlRootPwd  
}

# 隐藏nginx版本信息，需要在nginx源码包解压之后，编译之前执行
function nginxHidenVersion {
    cd $soureDownloadPath/$nginxPkgPath
    sed -i "s/${nginxVersion}/${nginxHidenVersion}/g" src/core/nginx.h
    sed -i "s/nginx\//${nginxServerName}\//g" src/core/nginx.h
    sed -i "s/\"NGINX\"/\"`echo ${nginxServerName}|tr '[a-z]' '[A-Z]'`\"/g" src/core/nginx.h
    sed -i "s/Server: nginx/Server: ${nginxServerName}/g" src/http/ngx_http_header_filter_module.c
    sed -i "s/<center>nginx</<center>${nginxServerName}</g" src/http/ngx_http_special_response.c
    sureOk $? "nginxHidenVersion"
}

# 初始化nginx初始配置
function initNginxConf {
    # 备份一下
    cp $nginxConfFile{,.bak_$(date +%F)}
    # 再清空
    cat /dev/null > $nginxConfFile
    cat >>$nginxConfFile<<EOF
worker_processes  $(grep "cpu cores" /proc/cpuinfo |awk '{print $4}');
events {
    worker_connections  1024;
}
http {
	include       mime.types;
	default_type  application/octet-stream;
	sendfile        on;
	keepalive_timeout  65;
	include extra/*.conf;
}
EOF
    # 创建存放虚拟主机目录，所有的虚拟主机存放在这个目录
    mkdir -p $installPath/$nginxSoftName/conf/extra
    sureOk $? "initNginxConf"
}

# 初始化php配置文件
function initPhpConf {
    \cp $soureDownloadPath/$phpPkgPath/php.ini-development $phpConfFile
    sureOk $? "initPhpConf"
}

# 初始化FastCGI配置文件
function initFasCGIConf {
    \cp $installPath/$phpSoftName/etc/php-fpm.conf.default $installPath/$phpSoftName/etc/php-fpm.conf
    \cp $installPath/$phpSoftName/etc/php-fpm.d/www.conf.default $installPath/$phpSoftName/etc/php-fpm.d/www.conf
    sureOk $? "initFasCGIConf"
}

# 把数据库的安装独立出来，这些是数据库软件单独安装的main函数
function alone_envMysqlEnv_Build_BeiMenChuiXue {
    GoYumRelayPkg  $mysqlSoftName $mysqlRelayPkg
    GoAddRunUser $mysqlRunUser
    GoDownload $mysqlDownloadUrl $mysqlSoftName
    GoUntar $mysqlPkgName
    GoConfigure $mysqlPkgPath $mysqlConfigure $mysqlSoftName "cmake"
    GoMake $mysqlPkgPath $mysqlSoftName
    GoMakeInstall $mysqlPkgPath $mysqlSoftName
    GoCreateSoftLink $mysqlPkgPath $mysqlSoftName
    GoGlobalSet $mysqlSoftName $mysqlBinPaht
    envMysqlExtraWork
}
# 如果mysql 和 php nginx 安装在同一个服务上，则取消这个注释
# alone_envMysqlEnv_Build_BeiMenChuiXue

# php 和 nginx环境搭建main函数
function main_LNMP_Build_BeiMenChuiXue {
    envYumRelayPkg
    envAddRunUser
    envPkgDownload
    envUntarPkg
    nginxHidenVersion
    envConfigure
    envMake
    envMakeInstall
    envCreateSoftLink
    envGlobalSet
    envOnboot
    initNginxConf
    initPhpConf
    initFasCGIConf
    envStart
}
main_LNMP_Build_BeiMenChuiXue

