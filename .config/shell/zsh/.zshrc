# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTSIZE=500000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=500000
setopt appendhistory
setopt HIST_IGNORE_ALL_DUPS
setopt nonomatch
# # options that should be mostly pretty agreeable: from https://github.com/willghatch/zsh-saneopt/blob/master/saneopt.plugin.zsh

# no c-s/c-q output freezing
setopt noflowcontrol
# # allow expansion in prompts
# setopt prompt_subst
# # this is default, but set for share_history
# setopt append_history
# # save each command's beginning timestamp and the duration to the history file
# # setopt extended_history
# # display PID when suspending processes as well
# setopt longlistjobs
# # try to avoid the 'zsh: no matches found...'
# setopt nonomatch
# # report the status of backgrounds jobs immediately
# setopt notify
# # whenever a command completion is attempted, make sure the entire command path
# # is hashed first.
# setopt hash_list_all
# # not just at the end
# setopt completeinword
# # use zsh style word splitting
# setopt noshwordsplit
# allow use of comments in interactive code
setopt interactivecomments

source ~/.local/share/zsh/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


export PYTHONPATH="$PYTHONPATH:$HOME/Codes"
export EDITOR=vim
if [ -f $HOME/.config/shell/aliases.sh ]; then
  source $HOME/.config/shell/aliases.sh
fi
# go
export PATH=$HOME/go/bin:$PATH

# fnm

if [ -d $HOME/.fnm ]; then
    export PATH=$HOME/.fnm:$PATH
    eval "`fnm env`"
fi


if [ -d $HOME/.pyenv ]; then
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
fi

export PATH=$PATH:/usr/local/go/bin


eval "$(zoxide init zsh)"

function confed(){
  env GIT_DIR=$HOME/.local/share/yadm/repo.git GIT_WORK_TREE=$HOME \
  vim -c "let g:rooter_change_directory_for_non_project_files = 'home'" \
      -c "silent AutoSaveToggle" \
      `yadmlistall`
}


# Plugins
source $HOME/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.local/share/zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $HOME/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.local/share/zsh/ohmyzsh/plugins/dirhistory/dirhistory.plugin.zsh
source $HOME/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh

zvm_after_init() {
  # Auto-completion
  # ---------------
  [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null

  # Key bindings
  # ------------
  source "$HOME/.fzf/shell/key-bindings.zsh"
  bindkey "\C-z" autosuggest-accept
  # bindkey "^M" autosuggest-accept
}
# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_COMPLETION_TRIGGER='óó'
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 --bind "alt-a:select-all,alt-d:deselect-all"'



_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

. "$HOME/.cargo/env"

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
