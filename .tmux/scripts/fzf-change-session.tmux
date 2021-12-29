#!/usr/bin/env bash

tmux_fzf_change_session() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"

  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "no sessions"
}

tmux_fzf_new_session() {
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  if [ -n $TMUX ]; then
      echo "sessions shoud be nested with care"; return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux new-session -t "$session" || echo "no sessions"
}

$1

