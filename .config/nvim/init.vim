set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
if exists('g:started_by_firenvim')
    source runtime firenvim.vim
else
    source runtime vimrc
endif
