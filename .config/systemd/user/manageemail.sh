#!/bin/bash

systemctl --user $@ throttle.service
systemctl --user $@ goimapnotify@elte.service
systemctl --user $@ goimapnotify@bence.service
systemctl --user $@ goimapnotify@pharmahungary.service
systemctl --user $@ goimapnotify@priestoferis.service
systemctl --user $@ mailsync-medium.timer
systemctl --user $@ mailsync-low.timer
