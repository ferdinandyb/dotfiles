# .files

I choose [yadm](https://github.com/TheLocehiliosan/yadm) because it is basically
a bare git repo if I don't need anything fancy, meaning the structure and files
are the same as on the machine, but it has the fancy things I occasionally need.

`.local/bin/yamdlistall` will list all files managed by `yamd` until hopefully
`yamd` will have a built-in [solution
](https://github.com/TheLocehiliosan/yadm/issues/392).

## bootstrap and update

Bootstrap will run on every `yadm clone` and `yadm pull`, so make bootstrap be
idempotent.

## airline themes for tmux and shell prompt

If you change the airline theme in vim, to have matching themes in tmux, open
vim inside a tmux session and execute:
```
:Tmuxline airline full
:TmuxlineSnapshot ~/.tmux/tmuxline_theme.sh
```

For the shell prompt execute:
```
:PromptlineSnapshot ~/.config/shell/promptline_theme.sh
```
