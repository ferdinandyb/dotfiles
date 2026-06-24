" Folding + Python text objects for classic vim only.
" On neovim these jobs are done by treesitter (folds) and
" nvim-treesitter-textobjects (text objects) — see nvim-plug-configs/.

" Python code folding
Plug 'tmhedberg/SimpylFold'
" Python text objects + motions (af/if, ac/ic, ad/id, ]]/[[, ]m/[m, ...)
Plug 'jeetsukumaran/vim-pythonsense'
" Cache expr/syntax folds so they are not recomputed on every edit
Plug 'Konfekt/FastFold'
