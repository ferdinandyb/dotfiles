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

## Installation (macOS)

```sh
# 1. Karabiner VirtualHIDDevice daemon (must start before kanata)
sudo cp ~/.config/kanata/service/org.bferdinandy.karabiner-vhiddaemon.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist

# 2. Kanata (waits for vhidd socket, restarts on crash)
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist
```

### Re-install (if already registered)

```sh
sudo launchctl bootout system/org.bferdinandy.karabiner-vhiddaemon
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.karabiner-vhiddaemon.plist

sudo launchctl bootout system/org.bferdinandy.kanata
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist
```

### Debug

```sh
# Check status
sudo launchctl list | grep bferdinandy

# Restart kanata
sudo launchctl kickstart -k system/org.bferdinandy.kanata

# Validate config without restarting
kanata --cfg ~/.config/kanata/mac.kbd --check

# Debug key events
sudo kanata --debug -c ~/.config/kanata/mac.kbd 2>&1 | grep "KeyEvent"
```
