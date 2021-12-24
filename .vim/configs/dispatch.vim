Plug 'tpope/vim-dispatch'

au FileType python nnoremap <Leader>r :Dispatch python3 %<CR>
autocmd BufRead,BufNewFile *.Rmd nnoremap <Leader>r :Dispatch R -e "rmarkdown::render('%',output_file='%.html')" <CR>
