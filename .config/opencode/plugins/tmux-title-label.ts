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
