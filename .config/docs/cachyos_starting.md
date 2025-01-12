
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
    asciidoc \
    bashmount \
    bat \
    blueman \
    brightnessctl \
    catdoc \
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
    glow \
    go \
    gofumpt \
    gopls \
    goimapnotify \
    gnome-keyring \
    gvim \
    lazygit \
    libsixel \
    libreoffice-fresh \
    i3-back \
    ipython \
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
    pavucontrol \
    perl-authen-sasl \
    perl-net-smtp-ssl \
    perl-mime-tools \
    pod2man \
    python-dateutil \
    python-i3ipc \
    python-pipx \
    ripgrep \
    rofi-greenclip \
    rsync \
    sasl-xoauth-git \
    sasl-xoauth2-git \
    speedtest-cli \
    spotify-launcher \
    scdoc \
    tig \
    tmux \
    tlp \
    unclutter \
    ugrep \
    xcape \
    xclip \
    xmlto \
    xss-lock \
    yadm \
    zoxide \
    watchexec \
    w3m \
    zip

pipx \
    mail-deduplicate \
    xlsx2csv

```

Enable services:

```
scu enable --now throttle.service
scu enable --now goimapnotify@pharmahungary.service
scu enable --now goimapnotify@elte_.service
scu enable --now goimapnotify@bence.service
scu enable --now goimapnotify@priestoferis.service
scu enable --now mailsync-low.timer
scu enable --now mailsync-medium.timer
```
