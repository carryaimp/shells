#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

downloadPath="$HOME/tools"
installPath="/application"
pyBinPath="python/bin"
pyVersion="3.6.4"
pyPkgName="Python-${pyVersion}"
pyDownloadUrl="https://www.python.org/ftp/python/${pyVersion}/${pyPkgName}.tgz"
pyRelayPkg="zlib-devel gcc gcc-c++ openssl-devel sqlite-devel wget"
pyVirtualPkg="virtualenvwrapper"

globalPath="/etc/profile"
vitrualEnvPath="$HOME/.pyenv"
userBashConf="$HOME/.bashrc"

. /etc/init.d/functions

function sureOK {
    [ $1 -eq 0 ] && {
        action "$2 is" /bin/true
    } || {
        action "$2 is" /bin/false
        exit $1
    }
}

[ -d $downloadPath ] || {
    mkdir -p $downloadPath
    sureOK $? "init downloadPath"
}

function pyRelayPkgInstall {
    echo "yum install python ...ing"
    yum install $pyRelayPkg &> /dev/null
    sureOK $? "pyRelayPkgInstall"
}
#pass pyRelayPkgInstall 

function downloadPyPkg {
    cd $downloadPath
    echo "dowbload python ...ing"
    wget -q $pyDownloadUrl
    sureOK $? "downloadPyPkg"
}
#pass downloadPyPkg

function untarPyPkg {
    cd $downloadPath
    tar -xf ${pyPkgName}.tgz
    sureOK $? "untarPyPkg"
}
#pass untarPyPkg

function pyConfigure {
    cd $downloadPath/$pyPkgName
    ./configure --enable-optimizations --prefix=$installPath/$pyPkgName --with-ssl &> /dev/null
    sureOK $? "pyConfigure"
}
#pass pyConfigure

function pyMakeAndMakeInstall {
    cd $downloadPath/$pyPkgName
    echo "make python ...ing, please wait ..ing"
    make &> /dev/null
    sureOK $? "pyMake"
    echo "make install python ...ing, please wait ..ing"
    make install &> /dev/null
    sureOK $? "pyMakeInstall"
}
#pass pyMakeAndMakeInstall

function pySoftLink {
    ln -s $installPath/$pyPkgName $installPath/python
    sureOK $? "pySoftLink"
}
#pass pySoftLink

function pyGlobalEnv {
    exportLineNum=`sed -n '/export PATH=/=' $globalPath`
    [ -z "$exportLineNum" ] && {
        echo "export PATH=\"$installPath/$pyBinPath:\$PATH\"" >> $globalPath
        sureOK $? "pyGlobalEnv"
    } || {
       middlePath= $(echo `sed -n '/export PATH=/p' $globalPath`| awk -F '[ "]' -v v=$installPath/$pyBinPath  '{print $1,$2"\""$2$3":"v"\""}')
       echo $middlePath
       sed -i "#exportLineNum s/.*/$middlePath/g" $globalPath
       sureOK $? "pyGlobalEnv"
    }
}
#pass pyGlobalEnv

function AliyunPipConf {
    [ -d $HOME/.pip ] || {
        mkdir $HOME/.pip -p
        sureOK $? "init .pip dir"
    }
    cd $HOME/.pip
    echo -e "[global]\ntrusted-host=mirrors.aliyun.com\nindex-url=http://mirrors.aliyun.com/pypi/simple/" > pip.conf
    sureOK $? "AliyunPipConf"
}
#pass AliyunPipConf

function pyVitrualenvInstall {
    . $globalPath
    pip3 install $pyVirtualPkg &> /dev/null
    sureOK $? "pyVitrualenvInstall"
}
#pass pyVitrualenvInstall

function createPyVitrualenv {
    [ -d $vitrualEnvPath ] || {
        mkdir -p $vitrualEnvPath
        sureOK $? "init vitrualEnvPath"
    }
    cat >>$userBashConf<<EOF
export VIRTUALENV_USE_DISTRIBUTE=1
export WORKON_HOME=$vitrualEnvPath
export VIRTUALENVWRAPPER_PYTHON=$installPath/$pyBinPath
. $installPath/$pyBinPath/virtualenvwrapper.sh
export PIP_VIRTUALENV_BASE=\$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
EOF
    sureOK $? "createPyVitrualenv"
}
#pass createPyVitrualenv

function persionPyVirtualCmdAlias {
    sed -i "9i alias mkenv='mkvirtualenv'\nalias rmenv='rmvirtualenv'\nalias outenv='deactivate'" $userBashConf
    sureOK $? "persionPyVirtualCmdAlias"
}
#pass persionPyVirtualCmdAlias

main_BeiMenChuiXue() {
    pyRelayPkgInstall
    downloadPyPkg
    untarPyPkg
    pyConfigure
    pyMakeAndMakeInstall
    pySoftLink
    pyGlobalEnv
    AliyunPipConf
    pyVitrualenvInstall
    persionPyVirtualCmdAlias
}
main_BeiMenChuiXue

# ^_^
