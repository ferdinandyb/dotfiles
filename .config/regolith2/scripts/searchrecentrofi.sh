#!/bin/bash

if [ -z "$@" ]
then
  fd --search-path=$HOME/Documents --search-path=$HOME/Codes --search-path=$HOME/Downloads --changed-within 2weeks
else
  xdg-open $@
  exit 0;
fi
