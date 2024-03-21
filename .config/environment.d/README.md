## Documentation

https://www.freedesktop.org/software/systemd/man/latest/environment.d.html


## Usage

Check result:

```
/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator
```

Reload for current login session:

```
systemctl --user daemon-reload
```

## Shell integration

Usually, one will launch terminals via a GUI that was already launched via systemd, meaning these environment variables are already loaded. There are two exceptions I know of: WSL and a tty. To circumvent this, the last `.conf` file to be loaded defines `SYSTEMDUSERENVLOADED=1` and for example a `.zshrc` can check for the existence of this, and if it is missing, manually load the environment variables, e.g.:

```
if [ "$SYSTEMDUSERENVLOADED" != 1 ]; then
  export $(systemctl --user show-environment | xargs)
fi
```

## Important note about precedence

These are all the files that are loaded:

- ~/.config/environment.d/*.conf
- /etc/environment.d/*.conf
- /run/environment.d/*.conf
- /usr/lib/environment.d/*.conf
- /etc/environment

> All configuration files are sorted by their filename in lexicographic order,
> regardless of which of the directories they reside in. If multiple files
> specify the same option, the entry in the file with the lexicographically
> latest name will take precedence. Thus, the configuration in a certain file
> may either be replaced completely (by placing a file with the same name in
> a directory with higher priority), or individual settings might be changed
> (by specifying additional settings in a file with a different name that is
> ordered later).

This means that if you want to make non-system files in `~/.config/` take
precedence, one must make sure they are last when sorted by name. Hence the
`X_` prefix for all of them.
