## Naming conventions

**Alias prefixes:**

- `b_xxx` — physical **b**utton aliases (platform-specific bottom-row mappings)
  - `b_ctl`, `b_alt`, `b_met`, `b_rmet` — defined in platform blocks in `core.kbd`
- `v_xxx` — **v**irtual action aliases (tap/hold actions assigned to buttons)
  - `v_chord` — modifier combo held with the super key (defined in `localkeys.kbd`)
  - `v_sup` — super-layer activator (tap=F20, hold=chord+super-layer)
  - `v_lal` — left-alt-layer activator (tap=lalt, hold=alt-layer)
  - `v_ral` — right-alt-layer activator (hold=ralt-layer)
- `vk_xxx` — kanata **v**irtual **k**eys (`defvirtualkeys`); boolean flags
  - `vk_num` — pressed = digits mode on num row; released = symbols mode
  - `vk_hu`  — pressed = bare Hungarian accents; released = AltGr accents
- `nx` — **n**um row aliases (`n0`–`n9`); check `vk_num` to fork digit/symbol
- `ax` — **a**ccent key aliases (`aö`, `aü`, `aó`, etc.); check `vk_hu` to fork bare/AltGr

**File structure:**

- `localkeys.kbd` — scancode mappings + `v_chord` (no forward refs, included first)
- `core.kbd` — all logic: `defvirtualkeys`, `defsrc`, `defalias`, bottom-row platform
  aliases (after `v_sup`/`v_lal`), layers

---

Debug keycodes:

sudo kanata --debug -c ~/.config/kanata/mac.kbd 2>&1 | grep "KeyEvent"
kanata --cfg ~/.config/kanata/mac.kbd --check


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


It's a system-level daemon (requires sudo). To restart:
sudo launchctl kickstart -k system/org.bferdinandy.kanata
The -k kills and restarts it in one shot. To just stop/start separately:
sudo launchctl stop org.bferdinandy.kanata
sudo launchctl start org.bferdinandy.kanata
