# Kanata Layout Plan

## Goal

A kanata layout inspired by Hungarian 101-key ISO, with identical behaviour across:
- macOS + Keychron K8 Pro ISO (external)
- macOS + built-in keyboard (Apple Internal Keyboard / Trackpad)
- Linux + ISO keyboard

## Base OS Layout

Both macOS and Linux are set to **Hungarian** as the OS-level keyboard layout.
This means the OS natively handles HU character production — kanata works on top
of this, performing inversions and layer customization rather than synthesizing
characters from scratch.

- **macOS**: input source is stock `Hungarian` (built-in macOS layout)
- **Linux**: keyboard layout set to `hu` (or equivalent)

Benefits:
- Number row `fork` inversion works naturally (OS already maps scancodes to HU chars)
- Far fewer `(unicode ...)` actions needed
- `deflocalkeys` entries map to real HU characters for readable configs
- macOS login screen (before kanata starts) behaves as a standard HU keyboard

## Features

1. **Inverted number row** — unshifted outputs the "shifted" symbol, shifted outputs the number
2. **Hungarian chars via alt** — both lalt and ralt act as layer-while-held; specific keys output Hungarian characters; unmapped keys pass the native modifier through to apps (Alt for lalt, AltGr for ralt)
3. **f24 prefix key** — Super/Win (Linux) or remapped bottom-row key (Mac) becomes f24; `f24+number` always outputs plain numbers regardless of number row inversion
4. **Mac bottom row swap** — after OS-level fn/ctrl swap: `lctl→lcmd`, `lopt→f24`, `lcmd→lopt`
5. **Linux system service** — kanata runs as a system-level systemd service, active at login screen and TTY

## Hardware

| Machine | Keyboard | Notes |
|---|---|---|
| macOS | Keychron K8 Pro ISO RGB (BT) | device name: `"Keychron K8 Pro"` |
| macOS | Apple Internal Keyboard / Trackpad | device name: `"Apple Internal Keyboard / Trackpad"` |
| Linux | ISO keyboard | device name: TBD (`kanata -l`) |

Both Mac keyboards are ISO layout and have the `102d` key — a single mac config
can target both via `macos-dev-names-include`. The Keychron is left in Linux mode
permanently, so it sends identical scancodes on both macOS and Linux; no per-keyboard
config differences are needed.

kanata binary path (macOS): `/opt/homebrew/bin/kanata`

### Keychron firmware config

A Via/Vial layout file exists at `~/.config/keyboards/keychron_k8_pro_iso_rgb.layout.json`.
The firmware is effectively stock — all layers use standard US scancodes (`KC_1`,
`KC_MINS`, etc.). The Mac layer bottom row uses `CUSTOM(0)`–`CUSTOM(3)` placeholders
with empty macros, meaning those keys currently do nothing at the firmware level.
This is intentional: all remapping is handled by kanata in software, so the firmware
config requires no changes.

**The Keychron is left permanently in Linux/Windows mode** (the hardware
switch). This means it sends standard scancodes (`KC_LCTL`, `KC_LGUI`, `KC_LALT`,
`KC_RALT`, `KC_RGUI`) on the bottom row regardless of which OS it is connected
to. The Mac-layer `CUSTOM(n)` entries are never active. This avoids needing to
physically toggle the switch when moving between machines, and ensures kanata
sees consistent scancodes on both macOS and Linux.

## File Structure

```
~/.config/kanata/
├── kanata-mac.kbd            ← entry: mac (covers both internal + Keychron)
├── kanata-linux-iso.kbd      ← entry: linux + ISO keyboard
└── shared/
    ├── localkeys.kbd         ← deflocalkeys-macos + deflocalkeys-linux
    └── core.kbd              ← defsrc, all layers, all aliases
```

Each entry point contains only a `defcfg` (with platform-specific device targeting)
plus two includes:

```clojure
(defcfg
  ;; platform-specific device targeting goes here
  ;; mac:   macos-dev-names-include
  ;; linux: linux-dev-names-include
)
(include shared/localkeys.kbd)
(include shared/core.kbd)
```

**Limitation:** included files cannot themselves include other files (only 1 level deep).
`platform` and `environment` blocks work fine inside included files.

The three entry points are nearly identical — they differ **only** in the `defcfg`
device targeting. All logic lives in `shared/core.kbd`. macOS vs Linux Hungarian
layout differences on the AltGr layer are irrelevant: all combos that matter are
explicitly mapped in the ralt/lalt layers, and transparent passthrough differences
don't affect anything in practice.

## defsrc

Uses US scancode key names. Both ISO keyboards (Keychron K8 Pro ISO and Apple
internal) physically match this layout:

```clojure
(defsrc
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  caps a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)
```

Physical HU key → US scancode name (with HU OS layout, these produce HU chars):
- `grv`  = `0/§` key (leftmost of number row)
- `-`    = `ö/Ö`
- `=`    = `ü/Ü`
- `[`    = `ő/Ő`
- `]`    = `ú/Ú`
- `;`    = `á/Á`
- `'`    = `é/É`
- `102d` = `í/Í` key (between lsft and z)

## Layers

Eight layers across two modes:

| Layer           | Active when              | Purpose                                               |
|---|---|---|
| `base`          | default                  | symbols on accent positions, numbers need shift       |
| `f24-layer`     | f24 held (in base)       | plain numbers + toggle to hu-prose                    |
| `lalt-layer`    | lalt held (in base)      | HU accents, Alt passthrough on unmapped               |
| `ralt-layer`    | ralt held (in base)      | HU accents, AltGr passthrough on unmapped             |
| `hu-prose-base` | after mode toggle        | HU accents on accent positions                        |
| `f24-layer-hu`  | f24 held (in hu-prose)   | plain numbers + toggle back to base                   |
| `lalt-layer-hu` | lalt held (in hu-prose)  | symbols on accent positions, Alt passthrough          |
| `ralt-layer-hu` | ralt held (in hu-prose)  | symbols on accent positions, AltGr passthrough        |

The two f24 layers are near-identical (plain numbers) except each carries the
toggle action pointing to the other mode. The two alt-layer pairs are inverses
of each other. `deftemplate` can reduce repetition.

## Key Mechanisms

### Inverted number row — `fork`

With HU base OS layout, the OS already maps scancodes to HU characters.
`fork` flips what the OS natively provides:

```clojure
;; (fork default-action shift-action (lsft rsft))
;; unshifted → symbol (HU shifted char), shift held → number
(defalias
  n0 (fork S-grv grv (lsft rsft))  ;; grv key: § unshifted, 0 shifted
  n1 (fork S-1 1 (lsft rsft))      ;; 1 key:   ' unshifted, 1 shifted
  n2 (fork S-2 2 (lsft rsft))      ;; 2 key:   " unshifted, 2 shifted
  n3 (fork S-3 3 (lsft rsft))      ;; 3 key:   + unshifted, 3 shifted
  n4 (fork S-4 4 (lsft rsft))      ;; 4 key:   ! unshifted, 4 shifted
  n5 (fork S-5 5 (lsft rsft))      ;; 5 key:   % unshifted, 5 shifted
  n6 (fork S-6 6 (lsft rsft))      ;; 6 key:   / unshifted, 6 shifted
  n7 (fork S-7 7 (lsft rsft))      ;; 7 key:   = unshifted, 7 shifted
  n8 (fork S-8 8 (lsft rsft))      ;; 8 key:   ( unshifted, 8 shifted
  n9 (fork S-9 9 (lsft rsft))      ;; 9 key:   ) unshifted, 9 shifted
)
```

With HU base, `S-1` tells the OS "shift + 1 scancode" which natively produces `'`.
No `(unicode ...)` needed — the OS does the character mapping.

### f24 key

Hold activates the appropriate f24 layer; tap does nothing (`nop0`):

```clojure
(defalias
  f24k (tap-hold 200 200 nop0 (layer-while-held f24-layer))
)
```

Both f24 layers override number keys with plain `1 2 3...` and map `ü`-position
to the mode toggle. All other keys are `_` (transparent).

```clojure
(deflayer f24-layer
  _   1    2    3    4    5    6    7    8    9    0    _    to-hu  _
  _   _    _    _    _    _    _    _    _    _    _    _    _      _
  _   _    _    _    _    _    _    _    _    _    _    _    _
  _   _    _    _    _    _    _    _    _    _    _    _    _
  _   _    _              _              _    _    _
)

(deflayer f24-layer-hu
  _   1    2    3    4    5    6    7    8    9    0    _    to-norm  _
  _   _    _    _    _    _    _    _    _    _    _    _    _        _
  _   _    _    _    _    _    _    _    _    _    _    _    _
  _   _    _    _    _    _    _    _    _    _    _    _    _
  _   _    _              _              _    _    _
)
```

The toggle aliases use `layer-switch` for persistent (non-momentary) mode change:

```clojure
(defalias
  to-hu   (layer-switch hu-prose-base)
  to-norm (layer-switch base)
)
```

AeroSpace/i3 binds `f24+1`, `f24+shift+1` etc. — always gets plain numbers
regardless of mode.

### Mode toggle — `f24+ü`

Two persistent modes, toggled with `f24` + the `ü` position key (`=` scancode):

- **Normal mode** (`base`): accent positions output punctuation; HU accents require alt
- **Hungarian prose mode** (`hu-prose-base`): accent positions output HU chars natively; punctuation requires alt

The f24 layer in each mode carries the toggle pointing to the other mode, so
it's always exactly two keys (`f24` + `ü-position`) regardless of current mode.

### Alt layers — two pairs, inverse of each other

Both `lalt` and `ralt` activate their own layer. Unmapped keys (`_`) are
transparent — the native modifier stays held:
- `ralt + unmapped` → OS AltGr+key (e.g., `\`, `|`, `[`, `{`, `@`)
- `lalt + unmapped` → OS Alt+key (app shortcuts)

**In normal mode** (`lalt-layer` / `ralt-layer`): mapped keys use `(unmod ...)`
to strip the modifier and let the OS produce the native HU character:
- `ö` on `-` position → `(unmod -)`
- `ü` on `=` position → `(unmod =)`
- `ő` on `[` position → `(unmod [)`
- `ú` on `]` position → `(unmod ])`
- `á` on `;` position → `(unmod ;)`
- `é` on `'` position → `(unmod ')`
- `í` on `102d` position → `(unmod 102d)`

**In hu-prose mode** (`lalt-layer-hu` / `ralt-layer-hu`): mapped keys output the
punctuation that the normal base layer provides on those positions. Exact
punctuation mappings TBD during fine-tuning.

### Mac bottom row

After OS-level fn↔ctrl swap, kanata sees: `lctl lopt lcmd`.
Target output: `lcmd f24 lopt`.

```clojure
(platform (macos)
  ;; lctl-position → lcmd
  ;; lopt-position → f24 (hold), nop (tap)
  ;; lcmd-position → lopt
)
```

### Linux bottom row

`lmet` (Super/Win key) → f24:

```clojure
(platform (linux)
  ;; lmet → f24 (hold), nop (tap)
)
```

## deflocalkeys

For readability — allows using HU character names in `defsrc` and `deflayer`.
Numbers are identical for both Linux and macOS for all main keyboard keys.

```clojure
(deflocalkeys-linux
  ö  12   ;; KEY_MINUS position
  ü  13   ;; KEY_EQUAL position
  ő  26   ;; KEY_LEFTBRACE position
  ú  27   ;; KEY_RIGHTBRACE position
  á  39   ;; KEY_SEMICOLON position
  é  40   ;; KEY_APOSTROPHE position
  í  86   ;; KEY_102ND position (ISO extra key left of Z)
)

(deflocalkeys-macos
  ö  12
  ü  13
  ő  26
  ú  27
  á  39
  é  40
  í  86
)
```

With these defined, `defsrc` can optionally be written as:

```clojure
(defsrc
  grv  1    2    3    4    5    6    7    8    9    0    ö    ü    bspc
  tab  q    w    e    r    t    y    u    i    o    p    ő    ú    \
  caps a    s    d    f    g    h    j    k    l    á    é    ret
  lsft í    z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)
```

## macOS Autostart

kanata requires the **Karabiner-DriverKit-VirtualHIDDevice** driver for keyboard
output on macOS. Three LaunchDaemon plists are needed in `/Library/LaunchDaemons/`:

1. `org.bferdinandy.karabiner-vhidmanager.plist` — activates the DriverKit extension
2. `org.bferdinandy.karabiner-vhiddaemon.plist` — Karabiner virtual HID daemon
3. `org.bferdinandy.kanata.plist` — kanata itself

Exact paths (confirmed present on this machine):
- VHIDManager: `/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate`
- VHIDDaemon: `/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon`
- kanata: `/opt/homebrew/bin/kanata -c /Users/bence.ferdinandy/.config/kanata/kanata-mac.kbd`

**One-time manual step**: add `/opt/homebrew/bin/kanata` to
`System Settings > Privacy & Security > Input Monitoring` (use the symlink path,
not the versioned Cellar path, so this survives `brew upgrade`).

**Known issue**: kanata crashes on macOS sleep/wake (upstream issue #1357). With
`KeepAlive: true` in the plist, launchd auto-restarts it — brief remapping gap
after wake is expected.

Plist files are documented here; see README for setup commands.

## Linux System Service

kanata runs as a **system-level systemd service** so remapping is active everywhere:
login screen, TTY, and graphical sessions.

Unit file (`~/.config/kanata/kanata.service`) kept in dotfiles:

```ini
[Unit]
Description=Kanata keyboard remapper
After=local-fs.target

[Service]
Type=simple
ExecStart=/usr/bin/kanata -c /home/<user>/.config/kanata/kanata-linux-iso.kbd
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
```

Setup (from README):
```bash
sudo ln -sf ~/.config/kanata/kanata.service /etc/systemd/system/kanata.service
sudo systemctl daemon-reload
sudo systemctl enable --now kanata
```

> **Note:** Binary path and username TBD for the Linux machine.

## macOS Login Screen

**Known limitation:** kanata does not run at the macOS login screen (it requires
a user session to be established before launchd starts user-space daemons with
HID permissions). Since the OS is set to stock Hungarian, the keyboard behaves
as a standard HU keyboard at login — numbers are unshifted, symbols are shifted.
This is perfectly usable for password entry.

## Open Questions

1. ~~**HU key positions for é and á**~~ → **Resolved:** `á` at `;` position (code 39), `é` at `'` position (code 40)
2. ~~**Built-in Mac keyboard has 102d?**~~ → **Resolved:** Yes — Mac16,6 MacBook Pro is ISO; Keychron K8 Pro is also ISO (product ID 0x0281 = ISO RGB variant)
3. **tap-hold timing** — 200ms threshold for f24 acceptable?
4. ~~**Device names (macOS)**~~ → **Resolved:** `"Apple Internal Keyboard / Trackpad"`, `"Keychron K8 Pro"`
5. ~~**§ output**~~ → **Resolved:** with HU base, `S-grv` natively produces `§`, no unicode needed
6. ~~**Number row symbols**~~ → **Resolved:** HU base handles this natively; `fork` just swaps shift state
7. **Accent position mappings** — exact punctuation output for ö/ü/ő/ú/á/é/í positions in normal mode TBD during fine-tuning; these also determine the hu-prose alt layer output
8. **Device names (Linux)** — need `kanata -l` output from the Linux machine
9. **Linux kanata binary and home path** — TBD for systemd service ExecStart

## HU ISO Number Row Reference

Physical key → unshifted / shifted on HU layout (what the OS produces with HU base):

| Physical key | Unshifted | Shifted | Inverted base output | Inverted shift output |
|---|---|---|---|---|
| grv position | 0 | § | § | 0 |
| 1 | 1 | ' | ' | 1 |
| 2 | 2 | " | " | 2 |
| 3 | 3 | + | + | 3 |
| 4 | 4 | ! | ! | 4 |
| 5 | 5 | % | % | 5 |
| 6 | 6 | / | / | 6 |
| 7 | 7 | = | = | 7 |
| 8 | 8 | ( | ( | 8 |
| 9 | 9 | ) | ) | 9 |
| - position (ö) | ö | Ö | TBD (base remap) | TBD |
| = position (ü) | ü | Ü | TBD (base remap) | TBD |

> **Note:** The `-` and `=` positions (ö, ü) have their base-layer output TBD.
> The native HU characters are accessible via the alt layers.

## Kanata Capabilities Summary

- `(platform (macos) ...)` / `(platform (linux) ...)` — platform-conditional config
- `(environment (VAR value) ...)` — env-var-conditional config (for keyboard differentiation)
- `(include file.kbd)` — include other files (1 level deep only; non-existing files silently ignored)
- `(deftemplate ...)` / `(template-expand ...)` — templates for reducing repetition
- `(fork a b (keys))` — output `a` by default, `b` if any of `keys` are held
- `(layer-while-held layer)` — activate a layer while a key is held
- `(tap-hold ms ms tap-action hold-action)` — different action for tap vs hold
- `(unicode char)` — output a unicode character
- `(unmod keys...)` — output key(s) with all modifiers released
- `kanata -l` — list available keyboard devices
