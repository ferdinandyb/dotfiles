#!/bin/bash

# partly copied from here: https://konfou.xyz/posts/sixel-for-terminal-graphics/

if [[ "$1" == "-g" ]]; then
  GEOMETRY="$2"
  shift 2
fi
for f in "$@"; do
  convert -density 300 "$f" -geometry ${GEOMETRY:=800x480} -alpha remove  sixel:-
done
