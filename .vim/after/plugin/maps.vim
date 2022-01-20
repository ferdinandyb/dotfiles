" Langmap is broken currently, see https://github.com/vim/vim/issues/3018


set langmap=\
            \ő[,
            \Ő{,
            \ú],
            \Ú},
            \é:,
            \á`,
            \ű',
            \ö<,
            \ü>,
            \ó=

nmap ő [
xmap ő [
omap ő [
nmap ú ]
omap ú ]
xmap ú ]
nmap Ő {
xmap Ő {
omap Ő {
nmap Ú }
omap Ú }
xmap Ú }

nmap ö <
nmap ü >
nmap ó =

" " you usually want to repeat in the same direction but altgr-, is complicated
" but it is handled by sneak now
" noremap , ;
" noremap ; ,

noremap <leader>ö :new<CR>
noremap <leader>ü :vnew<CR>


" there's a conflict with diffchar
nmap ]b <Plug>(unimpaired-bnext)
nmap [b <Plug>(unimpaired-bprevious)

noremap <leader>q :bd<cr> " quit buffer
noremap <leader>, :b#<cr> " alternate buffer

noremap <silent> K :call myfunctions#show_documentation()<CR>

noremap <leader>g :FGitFiles<cr>
noremap <leader>ft :FTags<cr>
noremap <leader>fr :FRg<space>
noremap <leader>fm :FMarks<cr>
noremap <leader>fl :FLines<cr>
noremap <leader>fw :FWindows<cr>
noremap <leader>fc :call vimtex#fzf#run()<cr>
noremap <leader>f :FFiles<cr>
noremap <leader>F :FAllFiles<cr>
noremap <leader>b :FBuffers<cr>
noremap <leader>: :FHistory<cr>
noremap <leader>é :FHistory<cr>
noremap <leader>/ :FHistory/<cr>
noremap <leader>gb :FGBranches<cr>


noremap <leader>ccn :CetliNew
noremap <leader>cn :FecniNew
noremap <leader>ccs :CetliSearch<CR>
noremap <leader>cs :FecniSearch<CR>
noremap <leader>ca :FecniSearchAll<CR>
noremap <leader>cb :BibtexciteInsert<CR>
noremap <leader>cg :Goyo<CR>

noremap <silent> s <nop>
noremap <silent> S <nop>

let g:textobj_sandwich_no_default_key_mappings = 1
xmap ib <Plug>(textobj-sandwich-auto-i)
omap ib <Plug>(textobj-sandwich-auto-i)
xmap ab <Plug>(textobj-sandwich-auto-a)
omap ab <Plug>(textobj-sandwich-auto-a)

xmap iq <Plug>(textobj-sandwich-query-i)
omap iq <Plug>(textobj-sandwich-query-i)
xmap aq <Plug>(textobj-sandwich-query-a)
omap aq <Plug>(textobj-sandwich-query-a)
