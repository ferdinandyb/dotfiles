#!/usr/bin/env bash

if [ -z "$@" ]; then
  greenclip print
else
  echo $1 | fmt -w 2000 | xclip -selection clipboard
  coproc (xdotool key --clearmodifiers "Shift+Insert" &)
  exit 0
fi
