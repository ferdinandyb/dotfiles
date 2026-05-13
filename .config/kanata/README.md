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

Kanata depends on Karabiner's VirtualHIDDevice-Daemon for its virtual keyboard
driver. Karabiner Elements must be installed; kanata reuses its stock vhidd daemon.
Only `karabiner_grabber` must be disabled — it conflicts with kanata.

```sh
# 1. Install Karabiner-Elements (provides the DriverKit virtual HID driver)
#    https://karabiner-elements.pqrs.org — open the app once to activate the driver

# 2. Disable karabiner_grabber (conflicts with kanata; kanata takes its place)
sudo launchctl bootout system/org.pqrs.service.daemon.karabiner_grabber 2>/dev/null || true
sudo launchctl disable system/org.pqrs.service.daemon.karabiner_grabber

# 3. Install the login-wait wrapper script (root-owned, see kanata-start.sh section below)
sudo cp ~/.config/kanata/service/kanata-start.sh /usr/local/bin/kanata-start.sh
sudo chown root:wheel /usr/local/bin/kanata-start.sh
sudo chmod 755 /usr/local/bin/kanata-start.sh

# 4a. Kanata — Apple internal keyboard
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.kanata.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist

# 4b. Kanata — Keychron K8 Pro (ISO extra key)
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata-iso.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/org.bferdinandy.kanata-iso.plist
sudo chmod 644 /Library/LaunchDaemons/org.bferdinandy.kanata-iso.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata-iso.plist
```

### Re-install (if already registered)

```sh
# Wrapper script
sudo cp ~/.config/kanata/service/kanata-start.sh /usr/local/bin/kanata-start.sh
sudo chown root:wheel /usr/local/bin/kanata-start.sh
sudo chmod 755 /usr/local/bin/kanata-start.sh

# Internal keyboard
sudo launchctl bootout system/org.bferdinandy.kanata
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata.plist /Library/LaunchDaemons/
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata.plist

# ISO (Keychron)
sudo launchctl bootout system/org.bferdinandy.kanata-iso
sudo cp ~/.config/kanata/service/org.bferdinandy.kanata-iso.plist /Library/LaunchDaemons/
sudo launchctl bootstrap system /Library/LaunchDaemons/org.bferdinandy.kanata-iso.plist
```

### Why karabiner_grabber must be disabled

`karabiner_grabber` is Karabiner's own key remapping engine. It grabs HID devices
exclusively at boot before kanata can. Symptoms when it is running: bottom-row keys
pass through as physical (Option is Option, Cmd is Cmd, í/grave not swapped), and
the ISO extra keys (left-of-1, left-of-Z) are reassigned to wrong scancodes.

Side effect of disabling: Karabiner-Menu tray icon no longer shows the current
device (cosmetic only).

`karabiner_grabber` is re-enabled by Karabiner's `SMAppService` mechanism on Karabiner
updates. Re-run the `launchctl bootout/disable` pair from step 2 if it comes back.

### `kanata-start.sh` — login-wait wrapper

The kanata LaunchDaemons start at boot (system domain, root), before any user logs
in. `karabiner_grabber` also starts at boot and grabs HID devices first. Even with
the grabber disabled, starting kanata immediately at boot can cause a race.

The wrapper script `/usr/local/bin/kanata-start.sh` polls `/dev/console` ownership:
- Before login it is owned by `loginwindow`
- After login it is owned by the logged-in user

Kanata only starts once a user is logged in, by which point the Bluetooth keyboard
should also be connected (connect it before logging in). The script must live in a
root-owned path (`/usr/local/bin/`) — not in `~/.config/` — to prevent privilege
escalation via a user-writable script running as root.

### Do NOT create LaunchAgents for kanata

The kanata plists must live in `/Library/LaunchDaemons/` (system domain, runs as
root). If copies also exist in `~/Library/LaunchAgents/` (user domain), launchd
will try to start duplicate instances that race for exclusive HID device access,
causing intermittent input freezes. The LaunchAgent copies serve no purpose; do not
create them.

### Debug

```sh
# Check status — karabiner_grabber must NOT be running; vhidd daemon should be
sudo launchctl print system | grep -iE "karabiner|pqrs|kanata"
launchctl list | grep kanata   # should return nothing (no user-domain agents)

# Check vhidd socket exists (created by Karabiner's stock vhidd daemon)
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
