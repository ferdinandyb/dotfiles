#!/bin/bash

if [ -z "$1" ]
  then
    origin="run-all-mbsync"
  else
    origin=$1
fi

# gathers all the channels in isyncrc
channels=$(grep '^Channel' $HOME/.config/isyncrc | sort | uniq | sed 's/Channel //')
# run the machine dependent channels
case $(hostname) in
  ("mashenka") echo "$channels" | grep -v ^yettel | xargs -i throttle --origin $origin --silent-job "testinternetconnection" --job "mbsync {}" --job "notmuch new";;
  ("BFERDINANDY-NB") echo "$channels" | grep ^yettel | xargs -i throttle --origin $origin --silent-job "testinternetconnection" --job "mbsync {}" --job "notmuch new";;
  (*)   echo "not on known machine";;
esac
