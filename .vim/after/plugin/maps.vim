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

noremap <leader>ö :new<CR>
noremap <leader>ü :vnew<CR>

" there's a conflict with diffchar
nmap ]b <Plug>(unimpaired-bnext)
nmap [b <Plug>(unimpaired-bprevious)

noremap <leader>q :bd<cr> " quit buffer
noremap <leader>, :b#<cr> " alternate buffer

nnoremap <silent> K :call myfunctions#show_documentation()<CR>

nnoremap <leader>fg :FGitFiles<cr>
nnoremap <leader>ft :FTags<cr>
nnoremap <leader>fr :FRg<space>
nnoremap <leader>fm :FMarks<cr>
nnoremap <leader>fl :FLines<cr>
nnoremap <leader>fw :FWindows<cr>
nnoremap <leader>fc :call vimtex#fzf#run()<cr>
nnoremap <leader>f :FFiles<cr>
nnoremap <leader>F :FAllFiles<cr>
nnoremap <leader>b :FBuffers<cr>
nnoremap <leader>: :FHistory<cr>
nnoremap <leader>é :FHistory<cr>
nnoremap <leader>/ :FHistory/<cr>
nnoremap <leader>fb :FGBranches<cr>


nnoremap <leader>cn :CetliNew
nnoremap <leader>cf :CetliFind<CR>
nnoremap <leader>cb :BibtexciteInsert<CR>
nnoremap <leader>cg :Goyo<CR>

noremap s <nop>
