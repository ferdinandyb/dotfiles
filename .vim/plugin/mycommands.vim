command! CocToggle call myfunctions#coc_toggle()
command! ALEFixToggle call myfunctions#ale_fix_toggle()


command! WrapHard call myfunctions#set_hardwrap()
command! WrapSoft call myfunctions#set_softwrap()
command -nargs=* -complete=file W w <args>
command -nargs=* -complete=file Wq wq <args>
