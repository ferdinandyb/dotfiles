Debug keycodes:

sudo kanata --debug -c ~/.config/kanata/kanata-mac.kbd 2>&1 | grep "KeyEvent"

Install as macOS LaunchDaemon (runs at boot as root):

sudo cp ~/.config/kanata/service/org.bferdinandy.kanata.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist

If already registered (re-install):

sudo launchctl bootout system/org.bferdinandy.kanata
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist
