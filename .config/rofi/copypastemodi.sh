#!/bin/bash

call_rofi () {
echo "running $1"
rofi -modi \
'clipboard:greenclip print,'\
'paste:~/.config/rofi/greenclip-paste-modi.sh,'\
'fmtpaste:~/.config/rofi/greenclip-paste-fmt-modi.sh,'\
'fmtclipboard:~/.config/rofi/greenclip-clipboard-fmt-modi.sh'\
 -show $1 -run-command '{cmd}'

}
case $1 in

    "clipboard")
        call_rofi "clipboard" ;;
    "paste")
        call_rofi "paste";;
    "fmtpaste")
        call_rofi "fmtpaste";;
    "fmtclipboard")
        call_rofi "fmtclipboard";;
esac
