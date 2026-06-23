Plug 'puremourning/vimspector'
Plug 'sagi-z/vimspectorpy', { 'do': { -> vimspectorpy#update() } }

let g:vimspector_install_gadgets = [ 'debugpy', 'CodeLLDB', 'delve' ]
let g:vimspectorpy#tmux#split = "h"
let g:vimspectorpy#tmux#size = 100
" for normal mode - the word under the cursor
nmap <leader>di <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <leader>di <Plug>VimspectorBalloonEval

nmap vc <Plug>VimspectorContinue
nmap vs <Plug>VimspectorStop
nmap vr <Plug>VimspectorRestart
nmap vp <Plug>VimspectorPause
nmap vb <Plug>VimspectorToggleBreakpoint
nmap vB <Plug>VimspectorToggleConditionalBreakpoint
nmap vf <Plug>VimspectorAddFunctionBreakpoint
nmap vo <Plug>VimspectorRunToCursor
nmap vj <Plug>VimspectorStepOver
nmap vl <Plug>VimspectorStepInto
nmap vh <Plug>VimspectorStepOut
nmap vw :VimspectorWatch
nmap vq :VimspectorReset<Enter>
nmap <F11> <Plug>VimspectorUpFrame
nmap <F12> <Plug>VimspectorDownFrame
nmap <Leader>B     <Plug>VimspectorBreakpoints
nmap <Leader>D     <Plug>VimspectorDisassemble
