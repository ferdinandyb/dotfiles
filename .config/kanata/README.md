# kanata config

Hungarian ISO layout on macOS and Linux. Two orthogonal mode flags drive the
num-row and accent-key behaviour. On both platforms it assumes that the
keyboard layout in the OS is set to Hungarian. The produced layout is identical
and _mostly_ follows the standard ISO layout for Hungarian (Mac has
a completely different alt layer for some reason by default).

## Usage

### Num-row mode (`vk_num`)

Toggle with **Super+ú**. Default: symbols mode.

| mode    | unshifted | shifted |
|---------|-----------|---------|
| symbols | HU special (`'`, `"`, `+`, …) | digit |
| digits  | digit | HU special |

### Accent-key mode (`vk_hu`)

Toggle with **Super+ű**. Switch to HU mode with **Super+ő** (sets both flags).
Default: special mode.

| mode    | plain press | alt held |
|---------|-------------|----------|
| special | symbol (`<`, `>`, `[`, …) | accent (`ö`, `ü`, `ó`, …) |
| HU      | accent | symbol |

### Alt layers

- **Left alt** (hold): activates alt-layer — accent keys output their symbols,
  num row passes digits. Tap sends a bare `lalt` for app shortcuts.
- **Right alt** (hold): activates ralt-layer — extra symbols (`[`, `]`, `{`, `}`,
  `#`, `&`, `@`, `|`, `;`, `*`, `™`, `°`, `€`).

### Super layer

Hold **Cmd+Alt** (macOS) / **Super** (Linux), then:

| key | action |
|-----|--------|
| ő   | switch to HU+digits mode |
| ú   | toggle digits mode |
| ű   | toggle HU mode |
| c   | live reload config |
| d   | toggle passthrough mode (cycle config) — _not yet implemented_ |
| num row | output plain digit regardless of mode |

---

## Naming conventions

- `b_xxx` — physical button aliases (platform-specific bottom-row mappings)
- `v_xxx` — virtual action aliases (tap/hold behaviours)
  - `v_chord` — modifier held with super key (Cmd+Alt on macOS, Super on Linux)
  - `v_sup` — super-layer activator (tap=F20, hold=chord+super-layer)
  - `v_lal` — left alt (tap=lalt, hold=alt-layer)
  - `v_ral` — right alt (hold=ralt-layer)
- `vk_xxx` — kanata virtual key flags (`defvirtualkeys`)
  - `vk_num` — digits mode on num row
  - `vk_hu`  — bare Hungarian accent mode
- `n0`–`n9` — num-row aliases; fork digit/symbol based on `vk_num`
- `aö`, `aü`, … — accent-key aliases; fork accent/symbol based on `vk_hu`

## File structure

- `localkeys.kbd` — scancode mappings, `SYM_*` vars, key aliases (included first)
- `core.kbd` — platform-agnostic logic: virtual keys, templates, layers
- `mac.kbd` / `linux-iso.kbd` — top-level entry points

---

## Installation (Linux)

The service file must be **copied** (not symlinked) to `/etc/systemd/system/` because
systemd runs as root and cannot traverse `/home/fbence` (`drwx------`).

```sh
sudo cp ~/.config/kanata/service/kanata.service /etc/systemd/system/kanata.service
sudo systemctl daemon-reload
sudo systemctl enable kanata.service
sudo systemctl start kanata.service
```

After editing `service/kanata.service`, re-copy and reload:

```sh
sudo cp ~/.config/kanata/service/kanata.service /etc/systemd/system/kanata.service
sudo systemctl daemon-reload
sudo systemctl restart kanata.service
```

### Debug

```sh
systemctl status kanata.service
journalctl -u kanata.service -f
```

---

## Installation (macOS)

Two kanata services exist — load only the one matching the active keyboard:

| Service label | Config | Device |
|---|---|---|
| `org.bferdinandy.kanata` | `mac-entry.kbd` | Apple Internal Keyboard / Trackpad |
| `org.bferdinandy.kanata-iso` | `mac-iso-entry.kbd` | Keychron K8 Pro |

```sh
# 1. Karabiner VirtualHIDDevice daemon (must start before kanata)
sudo cp ~/.config/kanata/service/org.bferdinandy.karabiner-vhiddaemon.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist

# 2a. Kanata — Apple internal keyboard (Mac-native ISO layout)
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist

# 2b. Kanata — Keychron K8 Pro (ISO extra key)
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata-iso.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.kanata-iso.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.kanata-iso.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata-iso.plist
```

### Re-install (if already registered)

```sh
sudo launchctl bootout system/org.bferdinandy.karabiner-vhiddaemon
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist

# Internal keyboard
sudo launchctl bootout system/org.bferdinandy.kanata
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist

# ISO (Keychron)
sudo launchctl bootout system/org.bferdinandy.kanata-iso
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata-iso.plist
```

### Debug

```sh
# Check status
sudo launchctl list | grep bferdinandy

# Restart kanata (pick the active one)
sudo launchctl kickstart -k system/org.bferdinandy.kanata
sudo launchctl kickstart -k system/org.bferdinandy.kanata-iso

# Validate configs without restarting
kanata --cfg ~/.config/kanata/mac-entry.kbd --check
kanata --cfg ~/.config/kanata/mac-iso-entry.kbd --check

# Debug key events
sudo kanata --debug -c ~/.config/kanata/mac-entry.kbd 2>&1 | grep "KeyEvent"
sudo kanata --debug -c ~/.config/kanata/mac-iso-entry.kbd 2>&1 | grep "KeyEvent"
```
