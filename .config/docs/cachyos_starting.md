
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
    htop \
    git-delta \
    go \
    gopls \
    goimapnotify \
    gnome-keyring \
    gvim \
    libsixel \
    isync \
    jq \
    msmtp \
    network-manager-applet \
    networkmanager \
    nm-connection-editor \
    nodejs \
    npm \
    notmuch \
    oama \
    pandoc \
    pass \
    python-dateutil \
    python-i3ipc \
    python-pipx \
    ripgrep \
    rofi-greenclip \
    rsync \
    sasl-xoauth-git \
    sasl-xoauth2-git \
    spotify-launcher \
    scdoc \
    tmux \
    ugrep \
    xclip \
    yadm \
    zoxide \
    w3m \
    zip

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
