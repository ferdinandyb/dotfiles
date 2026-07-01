"   opencode  <leader>a*   ask/prompt/select + prompt templates
"   operator  ga{motion} / gaa   (easy-align moved to gA, see vim-easy-align.vim)
"   99        <leader>k*   (kilenc): ks search, kv visual replace
"

Plug 'NickvanDyke/opencode.nvim'
Plug 'ThePrimeagen/99'

" opencode merges vim.g.opencode_opts into its config the first time that config
" loads, so set it now (before plug#end() loads the plugin) rather than in the
" PlugLoaded hook. Auto-discover a local `opencode --port` by CWD; when none is
" found, spawn one instead of nvim's slow embedded terminal. Inside tmux that's
" a *parked* window-99 pane (shared spawn path with the M-o toggle). Outside
" tmux: on macOS a Ghostty AppleScript split; on Linux Ghostty's only IPC
" action is new_window (no split over D-Bus), so a fresh Ghostty window.
lua << EOF
vim.g.opencode_opts = {
  server = {
    start = function()
      local cwd = vim.fn.getcwd()
      if vim.env.TMUX then
        vim.system({ vim.fn.expand("~/.tmux/scripts/opencode-pane"), "ensure" })
      elseif vim.fn.has("mac") == 1 then
        vim.system({
          "osascript",
          "-e", 'tell application "Ghostty"',
          "-e", 'split (focused terminal of front window) direction right'
              .. ' with configuration {command:"opencode --port 0",'
              .. ' initial working directory:"' .. cwd .. '"}',
          "-e", "end tell",
        })
      else
        vim.system({
          "ghostty", "+new-window", "--working-directory=" .. cwd,
          "-e", "opencode", "--port", "0",
        })
      end
    end,
  },
}
EOF

" --- opencode keymaps --------------------------------------------------------
nnoremap <leader>aa <cmd>lua require("opencode").ask("@this: ")<cr>
xnoremap <leader>aa <cmd>lua require("opencode").ask("@this: ")<cr>
nnoremap <leader>ap <cmd>lua require("opencode").prompt("@this")<cr>
xnoremap <leader>ap <cmd>lua require("opencode").prompt("@this")<cr>
nnoremap <leader>as <cmd>lua require("opencode").select()<cr>
xnoremap <leader>as <cmd>lua require("opencode").select()<cr>

" Prompt templates (fire immediately; swap prompt() -> ask() to edit first).
nnoremap <leader>ae <cmd>lua require("opencode").prompt("Explain @this and its context")<cr>
xnoremap <leader>ae <cmd>lua require("opencode").prompt("Explain @this and its context")<cr>
nnoremap <leader>af <cmd>lua require("opencode").prompt("Fix @diagnostics")<cr>
xnoremap <leader>af <cmd>lua require("opencode").prompt("Fix @diagnostics")<cr>
nnoremap <leader>ar <cmd>lua require("opencode").prompt("Review @this for correctness and readability")<cr>
xnoremap <leader>ar <cmd>lua require("opencode").prompt("Review @this for correctness and readability")<cr>
nnoremap <leader>ad <cmd>lua require("opencode").prompt("Add comments documenting @this")<cr>
xnoremap <leader>ad <cmd>lua require("opencode").prompt("Add comments documenting @this")<cr>
nnoremap <leader>at <cmd>lua require("opencode").prompt("Add tests for @this")<cr>
xnoremap <leader>at <cmd>lua require("opencode").prompt("Add tests for @this")<cr>

" Operator: ga{motion} sends a range, gaa sends the current line (dot-repeatable).
" Must be <expr> because operator() primes operatorfunc and returns 'g@'.
nnoremap <expr> ga luaeval('require("opencode").operator("@this ")')
xnoremap <expr> ga luaeval('require("opencode").operator("@this ")')
nnoremap <expr> gaa luaeval('require("opencode").operator("@this ")') . '_'

" --- 99 keymaps --------------------------------------------------------------
nnoremap <leader>ks <cmd>lua require("99").search()<cr>
xnoremap <leader>kv <cmd>lua require("99").visual()<cr>

" 99 needs setup() and the plugin must already be loaded, so run it on the
" User PlugLoaded hook (fired by vimrc right after plug#end()).
" Route 99 through the `kilenc` opencode agent instead of its hardcoded `--agent build`.
function! s:setup_99() abort
lua << EOF
local Providers = require("99.providers")
local base_build_command = Providers.OpenCodeProvider._build_command
local KilencProvider = setmetatable({}, { __index = Providers.OpenCodeProvider })
function KilencProvider._build_command(self, query, context)
  local cmd = base_build_command(self, query, context)
  for i = 2, #cmd do
    if cmd[i - 1] == "--agent" then
      cmd[i] = "kilenc"
    end
  end
  return cmd
end
require("99").setup({
  md_files = { "AGENTS.md" },
  model = "anthropic/claude-sonnet-5",
  tmp_dir = "$TMPDIR/opencode/99",
  provider = KilencProvider,
})
EOF
endfunction
autocmd User PlugLoaded ++nested call s:setup_99()
