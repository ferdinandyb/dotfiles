
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
    arandr \
    bashmount \
    bat \
    blueman \
    contour-git \
    ctags \
    cyrus-sasl \
    cyrus-sasl-xoauth2-git \
    dante \
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
    pandoc \
    pass \
    python-dateutil \
    python-pipx \
    ripgrep \
    rsync \
    sasl-xoauth-git \
    sasl-xoauth2-git \
    scdoc \
    tmux \
    ugrep \
    xclip \
    yadm \
    zoxide \
    w3m

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
