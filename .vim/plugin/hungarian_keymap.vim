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
xmap ö <
omap ö <

nmap ü >
xmap ü >
omap ü >

nmap ó =
xmap ó =
omap ó =

" I'm going to leave this here for now, but this should not be needed really
"
" nmap őa     :previous<cr>
" nmap úa     :next<cr>
" nmap őA     :first<cr>
" nmap úA     :last<cr>
" nmap őb     :bprevious<cr>
" nmap úb     :bnext<cr>
" nmap őB     :bfirst<cr>
" nmap úB     :blast<cr>
" nmap ől     :lprevious<cr>
" nmap úl     :lnext<cr>
" nmap őL     :lfirst<cr>
" nmap úL     :llast<cr>
" nmap ő<C-L> :lpfile<cr>
" nmap ú<C-L> :lnfile<cr>
" nmap őq     :cprevious<cr>
" nmap úq     :cnext<cr>
" nmap őQ     :cfirst<cr>
" nmap úQ     :clast<cr>
" nmap ő<C-Q> :cpfile<cr>
" nmap ú<C-Q> :cnfile<cr>
" nmap őt     :tprevious<cr>
" nmap út     :tnext<cr>
" nmap őT     :tfirst<cr>
" nmap úT     :tlast<cr>
" nmap ő<C-T> :ptprevious<cr>
" nmap ú<C-T> :ptnext<cr>

" nmap <C-w>ő :vert winc ]<cr>
" nmap <C-w><C-ő> :vert winc ]<cr>
