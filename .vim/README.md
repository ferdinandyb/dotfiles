# Vim / Neovim configuration

One modular config that runs on **both** classic Vim and Neovim, managed with
[vim-plug](https://github.com/junegunn/vim-plug).

Most of the setup is shared. Where Vim and Neovim need different plugins (e.g.
treesitter vs polyglot, gitsigns vs gitgutter, lualine vs airline), the config
splits into three buckets and `vimrc` loads the right ones via `has('nvim')`:

| bucket                 | loaded by            |
| ---------------------- | -------------------- |
| `common-plug-configs/` | both editors         |
| `vim-plug-configs/`    | classic Vim only     |
| `nvim-plug-configs/`   | Neovim only          |

Neovim gets here through `~/.config/nvim/init.vim`, which adds `~/.vim` to the
runtimepath and sources `vimrc`. So both editors run the same entry point.

Everything else follows standard Vim conventions: `plugin/` for always-on
settings, `after/plugin/` for things that must win over plugins (key maps),
`ftdetect/` + `after/ftplugin/` for filetype behaviour, `autoload/` for
on-demand functions.

## Keybindings

See **[`keybinds.md`](keybinds.md)** for the keymap. The leader is `Space` and
the maps are mnemonic and grouped by topic (`Space f …` find, `Space l …` LSP,
`Space v …` debug, and so on).

## Where things live

### Entry points
- `vimrc` — the main entry point (settings + plugin manager + the editor split)
- `coc-settings.json` — coc.nvim language-server config
- `firenvim.vim` — config for the Firenvim browser extension

### `plugin/` — always loaded
- `settings.vim` — core editor settings (encoding, search, mouse, …)
- `mycommands.vim` — custom commands
- `hungarian_keymap.vim` — Hungarian keyboard layout support

### `after/plugin/`
- `maps.vim` — key mappings, loaded after every plugin so they always win

### `ftdetect/` — early filetype detection
- `ros.vim` — `*.launch` → `roslaunch`
- `rmarkdown.vim` — `*.Rmd` → `markdown.rmarkdown`

### `common-plug-configs/` — both editors
Shared plugin declarations and per-plugin config:
- `plugins.vim` — shared plugin list
- `theme-setup.vim` — colorscheme (dracula) + general statusline options
- `common-git.vim` — shared git stack (fugitive, flog, twiggy, …)
- etc.

### `vim-plug-configs/` — classic Vim only
The Vim side of each dual split (no `has('nvim')` guard needed):
- `vim-theme-setup.vim` — airline + ecosystem (devicons, promptline, tmuxline)
- `vim-git.vim` — gitgutter (git signs)
- `vim-polyglot.vim` — polyglot syntax (Neovim uses treesitter instead)
- `vim-python-folds.vim` — SimpylFold + pythonsense + FastFold
- `vim-plugins.vim` — commentary + language syntax (Neovim uses native `gc` + treesitter)

### `nvim-plug-configs/` — Neovim only
The Neovim side, modern Lua plugins:
- `nvim.vim` — Neovim-only plugin list (treesitter, firenvim)
- `nvim-treesitter.vim` — treesitter highlight + folds + context + text objects
- `nvim-theme-setup.vim` — lualine (the airline replacement)
- `nvim-git.vim` — gitsigns (git signs)
- `opencode.vim` — opencode (AI agent) integration

### `after/ftplugin/` — per-filetype settings
`floggraph`, `gitcommit`, `help`, `javascript`, `latex`, `mail`, `markdown`,
`python`, `rmarkdown`, `vimwiki`, `vue`.

### `autoload/` — loaded on demand
- `contactfunction.vim` — contact/address helpers (email)
- `insertlinesfzf.vim` — fzf insert helpers
- `myfunctions.vim` — general utilities
- `plug.vim` — vim-plug itself

### Generated / cache (not interesting)
`plugged/` (installed plugins), `view/` (saved view state).

## Loading order

1. `vimrc` — basic settings + plugin manager
2. `ftdetect/` — early filetype detection
3. `plugin/` — always-on settings
4. plugin declarations: `common-plug-configs/`, then `nvim-plug-configs/`
   (Neovim) or `vim-plug-configs/` (Vim)
5. plugins install / initialise
6. `after/plugin/maps.vim` — key mappings
7. per filetype: `ftplugin/` → plugins → `after/ftplugin/`

## startup performance

I toyed around with this quite a bit. Switching neovim over to lualine and
treesitter made it noticable faster (I was able to drop a bunch of plugins
handling filetype nuances). But the biggest speeds was realising it's not
a good idea to have a binding `x`, when you also have `xy`, by default, the
timeout is a second, so don't do that kids.

```
nvim --headless --startuptime /tmp/st.log -c qa            # total = last line
vim  -es -N -u ~/.vim/vimrc --startuptime /tmp/st.log -c 'qa!'
```
