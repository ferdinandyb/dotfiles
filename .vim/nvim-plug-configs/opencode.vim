Plug 'NickvanDyke/opencode.nvim'

" opencode keymaps (leader = space)
nnoremap <leader>oa <cmd>lua require("opencode").ask("@this: ", { submit = true })<cr>
xnoremap <leader>oa <cmd>lua require("opencode").ask("@this: ", { submit = true })<cr>
nnoremap <leader>os <cmd>lua require("opencode").select()<cr>
xnoremap <leader>os <cmd>lua require("opencode").select()<cr>
nnoremap <leader>op <cmd>lua require("opencode").prompt("@this")<cr>
xnoremap <leader>op <cmd>lua require("opencode").prompt("@this")<cr>
nnoremap <leader>oo <cmd>lua require("opencode").toggle()<cr>
tnoremap <leader>oo <cmd>lua require("opencode").toggle()<cr>
