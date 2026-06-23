" Shared theme base for BOTH vim and neovim: colorscheme + general statusline
" options. The statusline plugin itself is split by editor:
"   - vim    -> airline   (vim-plug-configs/vim-theme-setup.vim, vim only)
"   - neovim -> lualine   (nvim-plug-configs/nvim-theme-setup.vim, neovim only)

Plug 'dracula/vim', { 'as': 'dracula' }

" sets the title to the open buffer, useful for tmux pane search
set title
" aerc dies on this sometimes it seems
if !exists("g:lightweight")
    set titlestring=VIM:\ %(%m%)%(%{expand(\"%:~\")}%)
endif

" Always show statusline
set laststatus=2
" set showtabline=2
set noshowmode

" this is needed for kitty background to work properly
let &t_ut=''

autocmd User PlugLoaded ++nested colorscheme dracula
