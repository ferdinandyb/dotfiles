" Git sign-column / hunk plugin for classic vim only.
" Neovim uses gitsigns instead (nvim-plug-configs/nvim-git.vim).
" Shared git plugins (fugitive, flog, ...) live in common-plug-configs/common-git.vim.

Plug 'airblade/vim-gitgutter'

" Relocate gitgutter's hunk text objects from ic/ac to ih/ah so vim-pythonsense
" keeps ic/ac (inner/outer class) in Python buffers. Defining maps to these
" <Plug> targets makes gitgutter's hasmapto() guard skip its own ic/ac defaults;
" all other default maps (]c/[c, <leader>hs/hu/hp) are left intact.
" This also matches the ih/ah hunk text objects used on the neovim/gitsigns side.
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
