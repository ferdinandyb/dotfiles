#!/bin/bash

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
task sync
tw_caldav_sync --caldav-url https://nc.vpn.ferdinandy.com/remote.php/dav/calendars/bence --caldav-calendar tw --caldav-user bence --caldav-passwd nextcloud/bence --all
