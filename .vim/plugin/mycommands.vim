command! CocToggle call myfunctions#coc_toggle()
command! ALEFixToggle call myfunctions#ale_fix_toggle()

" Customise the Files command to use rg which respects .gitignore files
command! -bang -nargs=? -complete=dir FFiles
            \ call fzf#run(fzf#wrap('files',
            \ fzf#vim#with_preview({
            \ 'source': 'rg --files --hidden'}), <bang>0))

" " Add an AllFiles variation that ignores .gitignore files
command! -bang -nargs=? -complete=dir FAllFiles
            \ call fzf#run(fzf#wrap('allfiles',
            \ fzf#vim#with_preview(
            \ { 'dir': <q-args>,
            \ 'source': 'rg --files --hidden --no-ignore' }),
            \ <bang>0))

" a command to search for files managed by yadm
command! -bang -nargs=? -complete=dir FYadm
            \ call fzf#run(fzf#wrap('yadm',
            \ fzf#vim#with_preview(
            \ { 'dir': <q-args>,
            \ 'source': 'yadmlistall' }), <bang>0))

command! WrapHard call myfunctions#set_hardwrap()
command! WrapSoft call myfunctions#set_softwrap()
command -nargs=* -complete=file W w <args>
command -nargs=* -complete=file Wq wq <args>
