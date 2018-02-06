#!/bin/sh

# author: beimenchuixue
# email: 422083556@qq.com
# blog: http://www.cnblogs.com/2bjiujiu/`

# 4 space == 1 tab, write or read files will display number of lines, vi = vim

. /etc/init.d/functions
# 1 copy, 2 write setting, 3 source 

one_shif=4
_tabstop=4

personal_vim() {
  [ -f /etc/vimrc ] && {
    cd $HOME
    /bin/cp /etc/vimrc .
    /bin/mv vimrc .vimrc
    echo -e "set nu\nset smartindent\nset tabstop=${_tabstop}\nset shiftwidth=${one_shif}\nset expandtab\nautocmd BufNewFile *.sh 0r /root/.vim/template/tmp.sh" >> .vimrc
    sed -i "5i alias vi='vim'" .bashrc
    [ -d .vim/template ] || {
        mkdir .vim/template -p
    }
    echo "#!/bin/sh\n" >> .vim/template/tmp.sh
    echo "# author: beimenchuixue" >> .vim/template/tmp.sh
    echo "# email: 422083556@qq.com" >> .vim/template/tmp.sh
    echo "# blog: http://www.cnblogs.com/2bjiujiu/" >> .vim/template/tmp.sh
    action "$HOME person vim setting is " /bin/true  
    }
}

personal_vim
