command! CocToggle call myfunctions#coc_toggle()
command! ALEFixToggle call myfunctions#ale_fix_toggle()
command! CocInlayToggle CocCommand document.toggleInlayHint

command! WrapHard call myfunctions#set_hardwrap()
command! WrapSoft call myfunctions#set_softwrap()
command! -bar MdFmt call myfunctions#md_fmt()
command! -nargs=* -complete=file W w <args>
command! -nargs=* -complete=file Wq wq <args>

command! FormatThousandWord call myfunctions#make_thousand_separators_word()
command! -range FormatThousandLine <line1>,<line2>call myfunctions#make_thousand_separators_line()
command! -nargs=1 Qshowfiles call myfunctions#quickfix_showfiles(<f-args>)
