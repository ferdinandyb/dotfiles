
Folders that need to be copied:
 - isync state
 - .mail
 - .ssh
 - .gnupg
 - .password-store
 - oama state

Things that need installing:

```
pacman -S paru
paru -S \
    bashmount \
    bat \
    contour-git \
    ctags \
    dust \
    element-desktop \
    fd \
    fzf \
    git-delta \
    go \
    goimapnotify \
    gvim \
    isync \
    jq \
    msmtp \
    network-manager-applet \
    networkmanager \
    nm-connection-editor \
    nodejs \
    notmuch \
    oama \
    pass \
    python-pipx \
    ripgrep \
    rsync \
    scdoc \
    tmux \
    ugrep \
    xclip \
    yadm \
    zoxide

pipx \
    mail-deduplicate

```

Enable services:

```
scu enable --now throttle.service
scu enable --now goimapnotify@pharmahungary_imapnotify.service
scu enable --now goimapnotify@elte_imapnotify.service
scu enable --now goimapnotify@bence_imapnotify.service
scu enable --now goimapnotify@priestoferis_imapnotify.service
scu enable --now mailsync-low.timer
scu enable --now mailsync-medium.timer
```
