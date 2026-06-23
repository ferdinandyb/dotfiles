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

-- git hunk counts from vim-gitgutter (we are not on gitsigns yet); lualine's
-- built-in `diff` source assumes gitsigns, so feed it gitgutter's summary.
local function gitgutter_diff()
  if vim.fn.exists('*GitGutterGetHunkSummary') == 0 then return nil end
  local s = vim.fn.GitGutterGetHunkSummary()
  return { added = s[1], modified = s[2], removed = s[3] }
end

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
      { 'diff', source = gitgutter_diff },
      { 'diagnostics', sources = { 'coc' } },
    },
    lualine_c = { 'filename' },
    lualine_x = {
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
