#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

downloadPaht="$HOME/tools"
installPath="/application"
phpRelayPkg="zlib-devel libxml2-devel libjpeg-devel libjpeg-turbo-devel libiconv-devel freetype-devel libpng-devel gd-devel libcurl-devel libxslt-devel libmcrypt-devel mhash mcrypt
"
version="7.0.0"
phpPkg="php-${version}"
phpDownloadUrl="http://mirrors.sohu.com/php/${phpPkg}.tar.gz"

. /etc/init.d/functions

function sureOk {
    [ "$1" -eq 0 ] && {
        action "$2 is" /bin/true
        return $1 
    } || {
        action "$2 is " /bin/false
        exit $1
    }
}

function installPhpRelayPkg {
    yum install -y $phpRelayPkg &> /dev/null
    sureOk $? "installPhpRelayPkg"
}
# installPhpRelayPkg

function installLibiconv {
    cd $downloadPaht
    wget -q http://down1.chinaunix.net/distfiles/libiconv-1.14.tar.gz
    sureOk $? "downlaod libiconv-devel"
    tar -xf libiconv-1.14.tar.gz
    sureOk $? "untar libiconv-devel"
    cd libiconv-1.14
    ./configure --prefix=/usr/local/libiconv &> /dev/null && make &> /dev/null && make install &> /dev/null
     sureOk $? "install libiconv-devel"
}
# installLibiconv

function downlaodPhp {
    cd $downloadPaht
    wget -q $phpDownloadUrl
    sureOk $? "downlaodPhp"
}
# downlaodPhp

function untarPhp {
    cd $downloadPaht
    tar -xf ${phpPkg}.tar.gz
    sureOk $? "untarPhp"
}
# untarPhp

function phpConfigure {
    cd $downloadPaht/${phpPkg}
    ./configure \
    --prefix=/application/php-7.0.0 \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=/usr/local/libiconv \
    --with-freetype-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib \
    --with-libxml-dir=/usr \
    --enable-xml \
    --disable-rpath \
    --enable-bcmath \
    --enable-shmop \
    --enable-sysvsem \
    --with-curl \
    --enable-mbregex \
    --enable-fpm \
    --enable-mbstring \
    --with-gd \
    --enable-gd-native-ttf \
    --with-openssl \
    --with-mhash \
    --enable-mcrypt \
    --enable-pcntl \
    --enable-sockets \
    --with-xmlrpc \
    --enable-soap \
    --enable-short-tags \
    --enable-static \
    --with-xsl \
    --with-fpm-user=nginx \
    --with-fpm-group=nginx \
    --enable-ftp \
    --disable-opcache &> /dev/null
    sureOk $? "phpConfigure"
}
# phpConfigure

function makeInstllPhp {
    cd $downloadPaht/${phpPkg}
    make &> /dev/null
    sureOk $? "phpMake"
    make install &> /dev/null
    sureOk $? "PhpMakeInstall"
}
# makeInstllPhp

function createPhpLink {
    ln -s $installPath/$phpPkg $installPath/php       
    sureOk $? "createPhpLink"
}
# createPhpLink

function cpPhpConf {
   \cp $downloadPaht/${phpPkg}/php.ini-development $installPath/php/lib/php.ini
   sureOk $? "cpPhpConf"
}
# cpPhpConf


function installPhpEnv_beimenchuixue_main {
    installPhpRelayPkg
    installLibiconv
    downlaodPhp
    untarPhp
    phpConfigure
    makeInstllPhp
    createPhpLink
    cpPhpConf    
}
# main func
installPhpEnv_beimenchuixue_main
