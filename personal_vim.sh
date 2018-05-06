#!/bin/sh

# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/`

# 4 space == 1 tab, write or read files will display number of lines, vi = vim

. /etc/init.d/functions

one_shif=4
_tabstop=4
vimConf="/etc/vimrc"
persionVimConf="$HOME/.vimrc"
templatePath="$HOME/.vim/template"
templateName="temp.sh"

function sureOk {
    [ $1 -eq 0 ] && {
        action "$2 is"  /bin/true
    } || {
        action "$2 is"  /bin/false
    }
}

function setVimConf {
    [ -f $persionVimConf ] || {
        cp $vimConf $persionVimConf
    }
    cat >>$persionVimConf<<EOF
set nu
set smartindent
set tabstop=${_tabstop}
set shiftwidth=${one_shif}
set expandtab
autocmd BufNewFile *.sh 0r $templatePath/$templateName
EOF
    sureOk $? "setVimConf"
    sed -i "5i alias vi='vim'" /$HOME/.bashrc
    sureOk $? "vi alias vim"
}

function setVimTemplate {
    [ -d $templatePath ] || {
        mkdir -p $templatePath
        sureOk $? "init templatePath"
    }
    cat >>$templatePath/$templateName<<EOF
#!/bin/sh
# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/

. /etc/init.d/functions

function sureOk {
    [ \$1 -eq 0 ] && {
        action "\$2 is"  /bin/true
    } || {
        action "\$2 is"  /bin/false
    }
}
EOF
    sureOk $? "setVimTemplate"
}

function main_BeiMenChuiXue {
    setVimConf
    setVimTemplate
}
main_BeiMenChuiXue
