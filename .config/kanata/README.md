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

## macOS ISO keyboard quirk

On macOS, the two "extra" ISO keys are assigned opposite scancodes depending on
the keyboard:

| Physical key | Apple internal | Keychron Windows mode |
|---|---|---|
| left of 1 | `KEY_102ND` (86) → `§/0` | `KEY_GRAVE` (41) → `í/Í` |
| left of Z | `KEY_GRAVE` (41) → `í/Í` | `KEY_102ND` (86) → `§/0` |

Apple uses a non-standard HID mapping for its ISO keyboards; a PC keyboard in
Windows mode follows the standard Linux/USB HID assignment but macOS interprets
those scancodes differently than Linux does.

This means the same kanata config cannot use a single scancode for both
**receiving** input (defsrc) and **emitting** output on the two macOS keyboards.
The fix is `nul_out`/`í_out` in `localkeys.kbd` — separate output scancodes that
produce the correct characters on each platform — and `v0`, a per-platform alias
used wherever a layer needs to emit the `§/0` key directly.

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
- `nul` / `í` — **input** scancodes for the §/0 and í/Í physical keys (differ per keyboard)
- `nul_out` / `í_out` — **output** scancodes for the same logical keys; needed because
  the Keychron K8 Pro in Windows mode sends scancodes that macOS HID interprets
  opposite to the Apple internal keyboard:
  - Apple internal: `KEY_GRAVE(41)` → `§/0`,  `KEY_102ND(86)` → `í/Í`
  - Keychron Windows: `KEY_GRAVE(41)` → `í/Í`, `KEY_102ND(86)` → `§/0`
  So input (`defsrc`) and output (layer emissions) need different scancode mappings
  for the Keychron. `nul_out`/`í_out` are the output variants. On Linux duplicate
  scancodes in `deflocalkeys` are not allowed, so `core.kbd` uses a `platform` block
  to fall back to `nul`/`í` directly.
- `v0` — alias that emits `nul_out` (macOS) or `nul` (Linux); used in `super-layer`
  to output a plain `0` keycode regardless of keyboard

## File structure

- `shared/localkeys.kbd` — per-platform scancode mappings including `nul_out`/`í_out`
- `shared/symbols.kbd` — `SYM_*` output key variables, per platform
- `shared/core.kbd` — platform-agnostic logic: `defsrc`, virtual keys, templates, layers
- `shared/bottomrow.kbd` — bottom-row tap/hold aliases
- `mac-entry.kbd` / `mac-iso-entry.kbd` / `linux-entry.kbd` — top-level entry points

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

Kanata depends on the standalone [Karabiner-DriverKit-VirtualHIDDevice](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice)
driver (v6.2.0) — **not** Karabiner-Elements. See the
[kanata macOS setup guide](https://github.com/jtroo/kanata/blob/main/docs/setup-macos.md)
for full prerequisites: driver installation, system extension activation and
approval, and granting kanata both **Input Monitoring** and **Accessibility**
permissions in System Settings > Privacy & Security.

Note: macOS invalidates permissions when the binary path changes or the binary is
replaced. After rebuilding from source or moving the binary, remove the stale entry
and re-add `/usr/local/bin/kanata` in both Input Monitoring and Accessibility.

```sh
# 1. Install the VHID daemon LaunchDaemon (standalone driver, no Karabiner-Elements)
sudo cp ~/.config/kanata/service/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist

# 2. Install kanata LaunchDaemons
# 2a. Kanata — Apple internal keyboard
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
# VHID daemon
sudo launchctl bootout system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
sudo cp ~/.config/kanata/service/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist /Library/LaunchDaemons/
sudo launchctl bootstrap system /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist

# Internal keyboard
sudo launchctl bootout system/org.bferdinandy.kanata
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata.plist /Library/LaunchDaemons/
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist

# ISO (Keychron)
sudo launchctl bootout system/org.bferdinandy.kanata-iso
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata-iso.plist /Library/LaunchDaemons/
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata-iso.plist
```

### Do NOT create LaunchAgents for kanata

The kanata plists must live in `/Library/LaunchDaemons/` (system domain, runs as
root). If copies also exist in `~/Library/LaunchAgents/` (user domain), launchd
will try to start duplicate instances that race for exclusive HID device access,
causing intermittent input freezes. The LaunchAgent copies serve no purpose; do not
create them.

### Debug

```sh
# Check status — vhidd daemon and both kanata services should be listed
sudo launchctl list | grep -iE "pqrs|kanata"
launchctl list | grep kanata   # should return nothing (no user-domain agents)

# Check vhidd socket exists (created by the standalone vhidd daemon)
sudo ls -la "/Library/Application Support/org.pqrs/tmp/rootonly/"

# Restart kanata (pick the active one)
sudo launchctl kickstart -k system/org.bferdinandy.kanata
sudo launchctl kickstart -k system/org.bferdinandy.kanata-iso

# Validate configs without restarting
kanata --cfg ~/.config/kanata/mac-entry.kbd --check
KANATA_MAC_ISO=1 kanata --cfg ~/.config/kanata/mac-iso-entry.kbd --check

# Debug key events (note: sudo resets env, pass var explicitly)
sudo kanata --debug -c ~/.config/kanata/mac-entry.kbd 2>&1 | grep "KeyEvent"
sudo KANATA_MAC_ISO=1 kanata --debug -c ~/.config/kanata/mac-iso-entry.kbd 2>&1 | grep "KeyEvent"

# Check kanata logs
tail -f /var/log/kanata.log
tail -f /var/log/kanata-iso.log
tail -f /var/log/kanata.err
tail -f /var/log/kanata-iso.err
```
