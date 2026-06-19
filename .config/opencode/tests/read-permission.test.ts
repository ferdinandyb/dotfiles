import { describe, it, expect } from "bun:test"
import fs from "node:fs"
import os from "node:os"
import path from "node:path"

// ── what this guards ─────────────────────────────────────────────────────────
// opencode's Read tool evaluates the `permission.read` ruleset against a
// WORKTREE-RELATIVE path (packages/opencode/src/tool/shell -> tool/read.ts:257:
// `patterns: [path.relative(instance.worktree, filepath)]`). So the current
// repo's own .git is seen as ".git" / ".git/config" with NO leading slash.
//
// opencode's Wildcard.match compiles "**/.git" -> ^.*.*/\.git$ and "**/.git/**"
// -> ^.*.*/\.git/.*.*$ — both require a "/" BEFORE ".git", so the "**/" forms
// only catch NESTED repos and MISS the worktree-root .git. The bare ".git" /
// ".git/**" forms are therefore required. This test locks that in and proves it.

// Vendored verbatim from opencode core/src/util/wildcard.ts @1.17.7. The shipped
// binary is Bun-compiled (no importable module), so we mirror the 11-line match()
// here. KEEP IN SYNC if opencode changes Wildcard.match (the opt-in
// tests/live-matrix.sh exercises the real binary end-to-end as a backstop).
function wildcardMatch(input: string, pattern: string): boolean {
  const normalized = input.replaceAll("\\", "/")
  let escaped = pattern
    .replaceAll("\\", "/")
    .replace(/[.+^${}()|[\]\\]/g, "\\$&")
    .replace(/\*/g, ".*")
    .replace(/\?/g, ".")
  if (escaped.endsWith(" .*")) escaped = escaped.slice(0, -3) + "( .*)?"
  return new RegExp("^" + escaped + "$", process.platform === "win32" ? "si" : "s").test(normalized)
}

// String-aware JSONC -> JSON so we can load the REAL config (this test guards the
// live opencode.jsonc, not a copy — deleting the .git denies fails this test).
// String-aware so the `https://` in "$schema" is not mistaken for a // comment.
function stripJsonc(src: string): string {
  let out = ""
  let inStr = false
  for (let i = 0; i < src.length; ) {
    const c = src[i]
    if (inStr) {
      out += c
      if (c === "\\") {
        out += src[i + 1] ?? ""
        i += 2
        continue
      }
      if (c === '"') inStr = false
      i++
      continue
    }
    if (c === '"') {
      inStr = true
      out += c
      i++
      continue
    }
    if (c === "/" && src[i + 1] === "/") {
      i += 2
      while (i < src.length && src[i] !== "\n") i++
      continue
    }
    if (c === "/" && src[i + 1] === "*") {
      i += 2
      while (i < src.length && !(src[i] === "*" && src[i + 1] === "/")) i++
      i += 2
      continue
    }
    out += c
    i++
  }
  return out.replace(/,(\s*[}\]])/g, "$1") // drop trailing commas
}

const CONFIG = path.join(os.homedir(), ".config", "opencode", "opencode.jsonc")
const config = JSON.parse(stripJsonc(fs.readFileSync(CONFIG, "utf8")))
const readRules = Object.entries(config.permission.read as Record<string, string>).map(([pattern, action]) => ({
  pattern,
  action,
}))

// Mirror opencode's evaluate(): last matching rule wins; default "ask".
const evaluateRead = (p: string): string =>
  readRules.findLast((r) => wildcardMatch(p, r.pattern))?.action ?? "ask"

const ruleset = (ns: string) =>
  Object.entries((config.permission[ns] ?? {}) as Record<string, string>).map(([pattern, action]) => ({
    pattern,
    action,
  }))
const editRules = ruleset("edit")
const extRules = ruleset("external_directory")
const evaluateEdit = (p: string): string => editRules.findLast((r) => wildcardMatch(p, r.pattern))?.action ?? "ask"
const evaluateExternalDir = (p: string): string =>
  extRules.findLast((r) => wildcardMatch(p, r.pattern))?.action ?? "ask"

// ── the config actually denies .git (incl. worktree-relative root) ───────────

describe("read permission: .git denied via the live opencode.jsonc ruleset", () => {
  it.each([
    ".git", // worktree-root .git dir (the case the **/ forms miss)
    ".git/config",
    ".git/refs/heads/main",
    "sub/.git", // nested repo dir
    "sub/.git/config",
    "../other/.git/config", // external repo via relative path
  ])("denies %s", (p) => expect(evaluateRead(p)).toBe("deny"))

  it.each([
    ".gitignore",
    ".github/workflows/ci.yml",
    "src/git.ts",
    "notgit/file",
    "vendor/gitlib/index.ts",
    "README.md",
  ])("allows %s", (p) => expect(evaluateRead(p)).toBe("allow"))
})

// ── root-cause: why both the relative and **/ forms are required ─────────────

describe("wildcard semantics: relative-form .git patterns are required", () => {
  it("the **/ forms ALONE miss the worktree-relative root .git (the bug)", () => {
    expect(wildcardMatch(".git", "**/.git")).toBe(false)
    expect(wildcardMatch(".git/config", "**/.git/**")).toBe(false)
  })
  it("the relative forms catch them (the fix)", () => {
    expect(wildcardMatch(".git", ".git")).toBe(true)
    expect(wildcardMatch(".git/config", ".git/**")).toBe(true)
  })
  it("the **/ forms still catch NESTED repos", () => {
    expect(wildcardMatch("sub/.git", "**/.git")).toBe(true)
    expect(wildcardMatch("sub/.git/config", "**/.git/**")).toBe(true)
  })
  it("no .git pattern false-matches .gitignore / .github", () => {
    for (const pat of [".git", ".git/**", "**/.git", "**/.git/**"]) {
      expect(wildcardMatch(".gitignore", pat), `${pat} vs .gitignore`).toBe(false)
      expect(wildcardMatch(".github/workflows/ci.yml", pat), `${pat} vs .github/...`).toBe(false)
    }
  })
})

// ── documents that "cmd *" matches the BARE command (settles the tree/pants
//    review note: wildcard.ts rewrites a trailing " .*" to "( .*)?") ──────────

describe("wildcard semantics: trailing ' *' also matches the bare command", () => {
  it.each(["tree", "pants check", "pants typecheck", "cd", "pwd", "cat", "ls"])(
    "'%s *' matches bare '%s'",
    (cmd) => expect(wildcardMatch(cmd, cmd + " *")).toBe(true),
  )
  it.each([
    ["tree", "tree -L 2 src"],
    ["pants check", "pants check ::"],
    ["cd", "cd /etc"],
  ])("'%s *' matches '%s'", (cmd, full) => expect(wildcardMatch(full, cmd + " *")).toBe(true))
})

// ── scratch dirs ($TMPDIR/opencode, /tmp/opencode) must not prompt ───────────
// The file tools route out-of-worktree access through external_directory (an
// absolute `<dir>/*` glob, external-directory.ts:30-37); the edit/write tool ALSO
// asks `edit` with the WORKTREE-RELATIVE path (write.ts:56). AGENTS.md designates
// these as pre-approved scratch, so both gates must allow them.

describe("external_directory allows the scratch dirs, still asks elsewhere", () => {
  it.each([
    "/tmp/opencode/*",
    "/var/folders/n0/f7xs46gn6j55vqyj_vx94dgh0000gp/T/opencode/*",
    "/var/folders/n0/f7xs46gn6j55vqyj_vx94dgh0000gp/T/opencode/sc/C/*", // nested depth
  ])("allows %s", (p) => expect(evaluateExternalDir(p)).toBe("allow"))

  it.each([
    "/tmp/*", // /tmp itself is shared → not blanket-allowed
    "/tmp/reinc_cfg/*",
    "/var/folders/n0/f7xs46gn6j55vqyj_vx94dgh0000gp/T/notopencode/*",
    "/Users/bence.ferdinandy/elsewhere/*",
  ])("still asks %s", (p) => expect(evaluateExternalDir(p)).toBe("ask"))
})

describe("edit allows scratch via the worktree-relative path", () => {
  it.each([
    "../../../../../var/folders/n0/f7xs46gn6j55vqyj_vx94dgh0000gp/T/opencode/fel380_pr_body.md",
    "../../../tmp/opencode/test_git_config.sh",
    "../../var/folders/n0/xxx/T/opencode/sc/D/cfg",
  ])("allows %s", (p) => expect(evaluateEdit(p)).toBe("allow"))

  it("does not blanket-allow an unrelated out-of-worktree path", () =>
    expect(evaluateEdit("../../some/other/place/file.txt")).not.toBe("allow"))
})
