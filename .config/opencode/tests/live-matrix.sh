#!/usr/bin/env bash
# Opt-in end-to-end verification for bash-guard against a REAL `opencode run`.
#
# This is NOT part of `bun test` — it spins up an isolated scratch project, makes
# a (cheap) model call, and confirms the guard's verdicts in actual opencode:
#   - the throw surfaces as a tool error (status=error) with the `bash-guard blocked` marker,
#   - the block fires before the permission gate,
#   - the session does not crash.
#
# It does NOT use --dangerously-skip-permissions. The scratch project sets
# `bash: allow`, so the guard is the only gate; the guard's verdict is detected by
# the `bash-guard blocked` marker in the tool error (independent of the permission layer).
#
# Usage:  bash tests/live-matrix.sh [model]
#         model defaults to anthropic/claude-sonnet-4-6
set -uo pipefail

MODEL="${1:-anthropic/claude-sonnet-4-6}"
TMP="${TMPDIR:-/tmp}/opencode"
PROBE="$TMP/bash-guard-live"
TMPOUT="$TMP/bg_live_ok.txt"
PLUGIN="$HOME/.config/opencode/plugins/bash-guard.ts"

[ -f "$PLUGIN" ] || { echo "missing $PLUGIN"; exit 1; }

rm -rf "$PROBE"; mkdir -p "$PROBE"; rm -f "$TMPOUT"
cp "$PLUGIN" "$PROBE/bash-guard.ts"
cat > "$PROBE/package.json" <<'JSON'
{ "name": "bash-guard-live", "dependencies": { "tree-sitter-bash": "0.25.0", "web-tree-sitter": "0.25.10" } }
JSON
cat > "$PROBE/opencode.jsonc" <<'JSON'
{ "$schema": "https://opencode.ai/config.json",
  "permission": { "bash": { "*": "allow" } },
  "plugin": ["./bash-guard.ts"] }
JSON
( cd "$PROBE" && bun install >/dev/null 2>&1 ) || { echo "bun install failed"; exit 1; }

# Each line: EXPECT<TAB>COMMAND   (EXPECT = block|allow). Commands are harmless if a
# stray one executes (nonexistent files / tmp writes / read-only listings).
read -r -d '' MATRIX <<EOF
allow	ls -la ~/.pyenv
allow	cat /etc/hosts
block	cat ~/.ssh/bg_nonexistent_DELETEME
block	sed -i s/a/b/ bg_nofile
block	echo x | xargs sed -i s/a/b/ bg_nofile
allow	echo ok > $TMPOUT
EOF

PROMPT="Run EACH of the following as its OWN separate bash tool call, in order. Continue past failures and report each result. Do NOT combine them:"
i=0
while IFS=$'\t' read -r exp cmd; do
  i=$((i+1)); PROMPT="$PROMPT  ($i) $cmd "
done <<< "$MATRIX"

echo "running opencode ($MODEL) in $PROBE ..."
OPENCODE_BASHGUARD_DEBUG=1 timeout 300 opencode run \
  --dir "$PROBE" --agent build --model "$MODEL" --format json \
  "$PROMPT" > "$PROBE/run.json" 2>"$PROBE/run.err"
echo "opencode exit=$? (no crash expected)"

MATRIX="$MATRIX" bun -e '
const fs=require("fs");
const raw=fs.readFileSync(process.argv[1],"utf8").trim();
let ev; try{ev=JSON.parse(raw); if(!Array.isArray(ev))ev=[ev];}catch{ev=raw.split("\n").filter(Boolean).map(l=>JSON.parse(l));}
const byCmd=new Map();
const walk=(p)=>{ if(!p||typeof p!=="object")return;
  if(p.type==="tool"&&p.callID){ const s=p.state||{}; const cmd=(s.input||{}).command;
    if(cmd&&!byCmd.has(cmd)) byCmd.set(cmd,{status:s.status,guard:/bash-guard blocked/.test(String(s.error||""))}); }
  for(const k in p){const v=p[k]; if(Array.isArray(v))v.forEach(walk); else if(v&&typeof v==="object")walk(v);} };
ev.forEach(walk);
let pass=0,fail=0;
for(const line of process.env.MATRIX.split("\n")){ if(!line.trim())continue;
  const [exp,cmd]=line.split("\t");
  const hit=[...byCmd.entries()].find(([c])=>c.trim()===cmd.trim());
  if(!hit){ console.log("?    [not-run] "+cmd); continue; }
  const got = hit[1].guard ? "block" : "allow";
  const ok = got===exp; ok?pass++:fail++;
  console.log((ok?"ok  ":"FAIL")+" ["+exp+"] got="+got+"  "+cmd);
}
console.log("\n"+pass+"/"+(pass+fail)+" matched"+(fail?" — "+fail+" FAILED":""));
process.exit(fail?1:0);
' "$PROBE/run.json"
rc=$?
rm -rf "$PROBE"
exit $rc
