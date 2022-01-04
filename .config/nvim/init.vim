set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
if exists('g:started_by_firenvim')
    source ~/.vim/configs/firenvim.vim
else
    source ~/.vim/vimrc
endif
