#!/bin/bash

if [ -d /home/linuxbrew/.linuxbrew/bin ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

task sync


if [ "$(hostname)" = "telekinuc" ]; then
  tw_caldav_sync \
    --caldav-url https://nc.vpn.ferdinandy.com/remote.php/dav/calendars/bence \
    --caldav-calendar tw \
    --caldav-user bence \
    --caldav-passwd nextcloud/bence \
    --all
fi
