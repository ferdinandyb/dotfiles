# .files

My dotfiles and explanations/documentation for myself.

## dotfile management

I use [yadm](https://github.com/TheLocehiliosan/yadm) because it is essentially a bare git repo, with some nice additional features.

`.local/bin/yadmlistall` will list all files managed by `yadm` until hopefully
`yadm` will have a built-in [solution
](https://github.com/TheLocehiliosan/yadm/issues/392).

## getting started

```
curl -fLo ~/.local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x ~/.local/bin/yadm
```

```
yadm clone https://github.com/ferdinandyb/dotfiles.git
```

Or if you have a key on the machine:
```
yadm clone git@github.com:ferdinandyb/dotfiles.git
```

### sparse-checkout and alternates

Way to set the classes (currently all alternates are based on this):

```
yadm config --add local.class imap
```

Current existing classes:
 - imap: set aerc to use imap instead of maildir
 - minimal: sparse-checkout
 - org: sparse-checkout

To use sparse-checkout after cloning set the appropriate classes then run:

```
yadm sparse-checkout reapply
```

See [sparse-checkout template](https://github.com/ferdinandyb/dotfiles/blob/master/.local/share/yadm/repo.git/info/sparse-checkout%23%23template).

### bootstrap and update

Don't bootstrap. It probably doesn't make sense with sparse-checkout anyway.

## Desktop

Regolith 3. Most notable customizations from base Regolith:

- switched back to `rofi` from `ilia` as it is more generic, with more community support;
- `flameshot` instead of `gnome-screenshot` with more useful bindings than Ubuntu/Regolith defaults
- `ranger` set up as default filebrowser: makes more sense for me to use the same as I would in the terminal

## Terminal stuff

- `kitty` although now looking at `contour` and `wezterm`
- `zsh`: took a long time to switch from bash, but the fast `powerlevel10k` prompt (vs `starship.rs` which lagged) was the final nail in the coffin, although I still have bash set up with `ble.sh`, which is pretty great (probably a bit better than what zsh provides through the vim-mode and syntax highlight plugins)
- `tmux`
- `fzf`, `fd-find`, `ripgrep`, and [ugrep](https://github.com/Genivia/ugrep) wherever they make sense
- `zoxide` for navigation: also integrates with `ranger`


### airline themes for tmux

If you change the airline theme in vim, to have matching themes in tmux, open
vim inside a tmux session and execute:
```
:Tmuxline airline full
:TmuxlineSnapshot ~/.tmux/tmuxline_theme.sh
```

## Email

I wrote a [tutorial](https://bence.ferdinandy.com/2023/07/20/email-in-the-terminal-a-complete-guide-to-the-unix-way-of-email/) which basically covers my setup.

Deduplication of emails:

```
for i in {2007..2022}; do mdedup $i -i maildir -s discard-all-but-one -a delete-discarded; done
```
