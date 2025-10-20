# ZDOTDIR=$HOME/.config/shell/zsh
# source . $ZDOTDIR/.zshenv
if [ -f $HOME/.cargo/env ]; then
. "$HOME/.cargo/env"
fi

# ZVM
export ZVM_INSTALL="$HOME/.zvm/self"
export PATH="$PATH:$HOME/.zvm/bin"
export PATH="$PATH:$ZVM_INSTALL/"
