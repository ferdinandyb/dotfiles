---
name: nvim-context
description: Read or control a neovim instance this opencode process is running under (embedded terminal, floaterm, or similar) via nvim's native --server/--remote* flags -- cursor position, visual selection, open a file at a line, list buffers, load a quickfix list, or run/send anything else. Use when editor context matters (the user says "the cursor", "my selection", "what I'm looking at") or a task should open a location or populate the quickfix list in their running neovim. Do nothing if $NVIM is unset -- there is no attached neovim to talk to.
---

# nvim-context

Replaces `mcp-neovim-server` (retired 2026-07-04, taskagent `agent-setup`
`7ef43ace`): that MCP was always-on (~20 tool defs costing context in every
session) and depended on a static `nvim --listen ./.nvim.sock` convention that's
easy to forget and doesn't target the right instance when opencode runs inside
a floaterm or embedded terminal. This is 6 one-line shell calls instead, using
neovim's own remote-control flags, no MCP server, no extra process.

## Precondition

Neovim auto-exports `$NVIM` into every terminal/job it spawns (`:terminal`,
floaterm, opencode.nvim's embedded pane, ...) pointing at that exact instance's
RPC socket. If `$NVIM` is empty, this opencode process isn't running under a
neovim instance -- skip all of the below rather than guessing at some other
socket.

```bash
[[ -n "$NVIM" ]] || echo "no attached neovim"
```

## 1. Cursor position + current file

```bash
nvim --server "$NVIM" --remote-expr "json_encode({'file': expand('%:p'), 'line': line('.'), 'col': col('.')})"
```

## 2. Visual selection

Marks `'<`/`'>` persist after leaving visual mode, so this works immediately
after a selection even though the mode itself has ended.

```bash
nvim --server "$NVIM" --remote-expr "json_encode({'file': expand('%:p'), 'start_line': getpos(\"'<\")[1], 'end_line': getpos(\"'>\")[1]})"
```

## 3. Open a file at a line

`--remote` directly supports a leading `+{cmd}` before the file. **Order
matters**: `--server` must come before `--remote`/`--remote-*` -- everything
after `--remote` is consumed as file names, so `--remote` before `--server`
silently swallows the server address as a filename.

```bash
nvim --server "$NVIM" --remote +{line} {file}
```

## 4. List open buffers

```bash
nvim --server "$NVIM" --remote-expr "json_encode(map(getbufinfo({'buflisted':1}), 'v:val.name'))"
```

## 5. Load a quickfix list

For handing the user a batch of file:line findings (review comments,
diagnostics, search results) to walk with `]q`/`[q`/`:cnext`. Write JSON to a
temp file first -- avoids shell-escaping a large payload inline. `type` is the
native vim quickfix severity (`E`/`W`/`I`/`N`), optional.

```bash
cat > /tmp/opencode/qf.json <<'JSON'
[
  {"filename": "src/foo.rs", "lnum": 42, "text": "[ISSUE] explanation", "type": "E"}
]
JSON
nvim --server "$NVIM" --remote-expr "execute('call setqflist(json_decode(join(readfile(\"/tmp/opencode/qf.json\"), \"\n\"))) | copen')"
```

## 6. Escape hatch

Anything not covered above: send raw keys, or evaluate any vimscript
expression and get its value back on stdout.

```bash
nvim --server "$NVIM" --remote-send "{keys}"
nvim --server "$NVIM" --remote-expr "{vimscript expression}"
```
