set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
if exists('g:started_by_firenvim')
    runtime! firenvim.vim
else
    runtime! vimrc
endif
