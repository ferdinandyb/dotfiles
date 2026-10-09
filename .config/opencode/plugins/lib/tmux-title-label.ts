export const MAX_TMUX_TITLE_LEN = 15

export function isResumeLaunch(argv: string[] = process.argv): boolean {
  return argv.some(
    (arg) =>
      arg === "-c" ||
      arg === "--continue" ||
      arg === "-s" ||
      arg === "--session" ||
      arg.startsWith("--session="),
  )
}

export function resolveTmuxPane(env: Record<string, string | undefined> = process.env): string | null {
  return env.TMUX_PANE || (env.TMUX && env.TMUX_PANE) || null
}

const DEFAULT_TITLE = /^(New session - |Child session - )\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/

export function extractTmuxLabel(rawTitle?: string | null): string | null {
  if (!rawTitle) return null
  const trimmed = rawTitle.trim()
  if (!trimmed || DEFAULT_TITLE.test(trimmed)) return null

  const pipe = trimmed.indexOf("|")
  const source = (pipe === -1 ? trimmed : trimmed.slice(0, pipe)).trim()
  if (!source) return null

  const sanitized = source
    .toLowerCase()
    .replace(/[^\p{L}\p{N}-]+/gu, "-")
    .replace(/^-+|-+$/g, "")
  if (!sanitized) return null

  const label = sanitized.slice(0, MAX_TMUX_TITLE_LEN).replace(/-+$/, "")
  return label || null
}

export type SessionStatusIcon = "●" | "?" | "✓" | "✗" | ""

export interface SessionStatusSource {
  status(id: string): "idle" | "running"
  pending?: { list(id: string): Array<{ type: string }> }
  permission?: { list(id: string): Array<unknown> | undefined }
  form?: { list(id: string): Array<unknown> | undefined }
  get(id: string): { outcome?: "succeeded" | "failed" | "interrupted" | string } | undefined
}

export function deriveSessionStatus(
  rootID: string,
  members: string[],
  source: SessionStatusSource,
): SessionStatusIcon {
  const needsInput = members.some(
    (id) => (source.permission?.list(id)?.length ?? 0) > 0 || (source.form?.list(id)?.length ?? 0) > 0,
  )
  if (needsInput) return "?"

  const isBusy = members.some(
    (id) =>
      source.status(id) === "running" ||
      (source.pending?.list(id) ?? []).some((item) => item.type !== "synthetic"),
  )
  if (isBusy) return "●"

  const rootSession = source.get(rootID)
  if (rootSession?.outcome === "failed") return "✗"
  if (rootSession?.outcome === "succeeded") return "✓"

  return ""
}
