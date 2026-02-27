Debug keycodes:

sudo kanata --debug -c ~/.config/kanata/mac.kbd 2>&1 | grep "KeyEvent"

Install as macOS LaunchDaemons (runs at boot as root):

# 1. Karabiner VirtualHIDDevice daemon (must start before kanata)
sudo cp ~/.config/kanata/service/org.bferdinandy.karabiner-vhiddaemon.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist

# 2. Kanata (starts only once vhidd socket exists, restarts on crash)
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist

Re-install (if already registered):

sudo launchctl bootout system/org.bferdinandy.karabiner-vhiddaemon
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist

sudo launchctl bootout system/org.bferdinandy.kanata
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist

Check status:

sudo launchctl list | grep bferdinandy
