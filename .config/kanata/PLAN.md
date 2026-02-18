# Kanata Layout Plan

## Goal

A kanata layout inspired by Hungarian 101-key ISO, with identical behaviour across:
- macOS + external ISO keyboard
- macOS + built-in keyboard
- Linux + ISO keyboard

## Features

1. **Inverted number row** — unshifted outputs the "shifted" symbol, shifted outputs the number
2. **Hungarian chars via ralt** — ralt acts as layer-while-held; specific keys output Hungarian unicode; unmapped keys pass ralt+key through to apps
3. **f24 prefix key** — Super/Win (Linux) or remapped bottom-row key (Mac) becomes f24; `f24+number` always outputs plain numbers regardless of number row inversion
4. **Mac bottom row swap** — after OS-level fn/ctrl swap: `lctl→lcmd`, `lopt→f24`, `lcmd→lopt`

## File Structure

```
~/.config/kanata/
├── kanata-mac-iso.kbd        ← entry: mac + external ISO keyboard
├── kanata-mac-builtin.kbd    ← entry: mac + built-in keyboard
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

## defsrc

Uses US scancode key names. The HU ISO keyboard physically matches this layout:

```clojure
(defsrc
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  caps a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft 102d z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)
```

Physical HU key → US scancode name:
- `grv`  = `0/§` key (leftmost of number row)
- `-`    = `ö/Ö`
- `=`    = `ü/Ü`
- `[`    = `ő/Ő`
- `]`    = `ú/Ú`
- `102d` = `í/Í` key (between lsft and z)

> **TODO:** confirm full right-side key positions (é, á) before implementing ralt layer.

For `kanata-mac-builtin.kbd`: if the built-in keyboard is non-ISO, `defsrc` will omit `102d`.

## Layers

Three layers:

| Layer | Active when | Purpose |
|---|---|---|
| `base` | always | main remapped layout |
| `f24-layer` | f24-key held | number keys output plain numbers |
| `ralt-layer` | ralt held | Hungarian unicode on specific keys, transparent elsewhere |

## Key Mechanisms

### Inverted number row — `fork`

```clojure
;; (fork default-action shift-action (lsft rsft))
;; unshifted → symbol, shift held → number
(defalias
  n0 (fork § 0 (lsft rsft))    ;; grv key: § unshifted, 0 shifted
  n1 (fork S-1 1 (lsft rsft))  ;; 1 key:   ! unshifted, 1 shifted
  n2 (fork S-2 2 (lsft rsft))  ;; 2 key:   " unshifted, 2 shifted
  n3 (fork + 3 (lsft rsft))    ;; 3 key:   + unshifted, 3 shifted
  ;; ... etc
)
```

No separate shifted layer needed — `fork` handles both states transparently.

### f24 key

Hold activates `f24-layer`; tap does nothing (`nop0`):

```clojure
(defalias
  f24k (tap-hold 200 200 nop0 (layer-while-held f24-layer))
)
```

The `f24-layer` overrides number keys with plain `1 2 3...` output, overriding the
`fork` aliases from the base layer. All other keys are `_` (transparent).

```clojure
(deflayer f24-layer
  _   1    2    3    4    5    6    7    8    9    0    _    _    _
  _   _    _    _    _    _    _    _    _    _    _    _    _    _
  _   _    _    _    _    _    _    _    _    _    _    _    _
  _   _    _    _    _    _    _    _    _    _    _    _    _
  _   _    _              _              _    _    _
)
```

AeroSpace/i3 binds `f24+1`, `f24+shift+1` etc. — always gets plain numbers.

### ralt layer — Hungarian characters

```clojure
(defalias
  ralt-k (layer-while-held ralt-layer)
)
```

Unmapped keys (`_`) are transparent — ralt stays held, so `ralt+key` passes through
to the OS/apps for shortcuts that use ralt.

Hungarian char positions to fill in once key positions are confirmed:
- `ö` on `-` position (ralt+-)
- `ü` on `=` position (ralt+=)
- `ő` on `[` position (ralt+[)
- `ú` on `]` position (ralt+])
- `í` on `102d` position (ralt+102d)
- `é`, `á` — positions TBD

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

Minimal — mainly for readability since the OS uses US layout.
Unicode characters output via `(unicode ...)` actions in aliases.

## Open Questions

1. **HU key positions for é and á** — which US-position keys are they on?
2. **Built-in Mac keyboard** — does it have a `102d` key? (ISO vs non-ISO built-in)
3. **tap-hold timing** — 200ms threshold for f24 acceptable?
4. **Device names** — need `kanata -l` output from each machine for `defcfg` device targeting
5. **§ output** — `§` will be output as `(unicode §)`; confirm this is the character wanted on that key unshifted
6. **Number row symbols** — confirm what the HU shifted symbols are for each number key (e.g. 3→+ or 3→#?)

## HU ISO Number Row Reference

Physical key → unshifted / shifted on a real HU keyboard:

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
| - position | ö | Ö | ; (US equiv) | : |
| = position | ü | Ü | [ (US equiv) | { |
| (no key) | ó | Ó | = (US equiv) | + |

> **Note:** The `-` and `=` positions on HU ISO map to ö and ü.
> Their "inverted" unshifted output should be the US equivalent punctuation (`;`, `[`),
> with the Hungarian character accessible via ralt.

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
