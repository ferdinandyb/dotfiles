# .files

My dotfiles and explanations/documentation for myself.

## dotfile management

I choose [yadm](https://github.com/TheLocehiliosan/yadm) because it is basically
a bare git repo if I don't need anything fancy, meaning the structure and files
are the same as on the machine, but it has the fancy things I occasionally need.

`.local/bin/yamdlistall` will list all files managed by `yamd` until hopefully
`yamd` will have a built-in [solution
](https://github.com/TheLocehiliosan/yadm/issues/392).

### bootstrap and update

Bootstrap will run on every `yadm clone` and `yadm pull`, so make bootstrap be
idempotent.

## Desktop

Regolith 2. Most notable customizations from base Regolith:

- switched back to `rofi` from `ilia` as it is more generic, with more community support;
- `scrot` instead of `gnome-screenshot` with more useful bindings than Ubuntu/Regolith defaults
- `ranger` set up as default filebrowser: makes more sense for me to use the same as I would in the terminal

## Terminal stuff

- `kitty`
- `zsh`: took a long time to switch from bash, but the very `powerlevel10k` prompt (vs `starship.rs` which lagged) was the final say, although I still have bash set up with `ble.sh`, which is pretty great (probably a bit better than what zsh provides through the vim-mode and syntax highlight plugins)
- `tmux`
- `fzf`, `fd-find`, `ripgrep` wherever they make sense
- `zoxide` for navigation: also integrates with `ranger`


### airline themes for tmux

If you change the airline theme in vim, to have matching themes in tmux, open
vim inside a tmux session and execute:
```
:Tmuxline airline full
:TmuxlineSnapshot ~/.tmux/tmuxline_theme.sh
```
