" Neovim statusline: lualine.
" Vim uses airline instead (vim-plug-configs/vim-theme-setup.vim).
" Shared colorscheme/settings live in common-plug-configs/theme-setup.vim.

Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lualine/lualine.nvim'

" lualine must be configured AFTER plug#end() has added it to the runtimepath.
" The vimrc fires `User PlugLoaded` right after plug#end(), same hook the
" colorscheme uses.
function! s:setup_lualine() abort
lua << EOF
local ok, lualine = pcall(require, 'lualine')
if not ok then return end

-- spell language indicator (airline_detect_spell): show only when spell is on.
local function spell()
  if not vim.wo.spell then return '' end
  return 'SPELL[' .. vim.bo.spelllang .. ']'
end

-- word count (always on). visual_words is set while a selection is active.
local function wordcount()
  local wc = vim.fn.wordcount()
  return (wc.visual_words or wc.words) .. 'w'
end

-- opencode connection status (idle/busy/error/disconnected icon + server url).
-- Guarded so a missing/broken opencode.nvim never takes down the statusline.
local oc_ok, oc = pcall(require, 'opencode')
local opencode_status = oc_ok and oc.statusline or function() return '' end

lualine.setup({
  options = {
    theme = 'auto',                 -- derive colors from the dracula colorscheme
    icons_enabled = true,           -- needs nvim-web-devicons
    section_separators = { left = '', right = '' },   -- U+E0B0 / U+E0B2 powerline arrows
    component_separators = { left = '', right = '' }, -- U+E0B1 / U+E0B3 thin chevrons
    globalstatus = false,           -- per-window, like the old laststatus=2 airline
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      'branch',
      { 'diff', source = function()
          local gs = vim.b.gitsigns_status_dict
          if gs then return { added = gs.added, modified = gs.changed, removed = gs.removed } end
      end },
      { 'diagnostics', sources = { 'coc' } },
    },
    lualine_c = { 'filename' },
    lualine_x = {
      opencode_status,
      spell,
      wordcount,
      'searchcount',
      'encoding',
      'fileformat',
      'filetype',
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location', 'selectioncount' },
  },
  tabline = {
    lualine_a = { { 'buffers', mode = 4 } },       -- mode 4: name + buffer number
    lualine_z = { 'tabs' },
  },
})
EOF
endfunction

autocmd User PlugLoaded ++nested call s:setup_lualine()
