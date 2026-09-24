import { type Plugin, tool } from "@opencode-ai/plugin"
import { spawnSync } from "node:child_process"
import { extractTmuxLabel, isResumeLaunch } from "./tmux-title-label"

function tmux(args: string[]) {
  spawnSync("tmux", args, { stdio: "ignore" })
}

function applyTitle(paneId: string, label: string | null, last: { label: string | null }, force = false) {
  if (!force && label === last.label) return
  last.label = label
  const set = label
    ? ["set-option", "-p", "-t", paneId, "@opencode_title", label]
    : ["set-option", "-p", "-u", "-t", paneId, "@opencode_title"]
  tmux([
    ...set,
    ";",
    "if-shell",
    "-t",
    paneId,
    "-F",
    "#{automatic-rename}",
    `set-window-option -t ${paneId} automatic-rename on`,
  ])
}

export default (async ({ client }) => {
  const paneId = process.env.TMUX && process.env.TMUX_PANE ? process.env.TMUX_PANE : null

  const setSessionTitle = tool({
    description: "Set the OpenCode session title. Pass `<label> | <full title>`.",
    args: { title: tool.schema.string() },
    async execute(args, ctx) {
      await client.session.update({ path: { id: ctx.sessionID }, body: { title: args.title } })
      return args.title
    },
  })

  if (!paneId) {
    return { tool: { set_session_title: setSessionTitle } }
  }

  let currentSessionId: string | null = null
  const last = { label: null as string | null }

  async function sync(
    sessionId: string,
    opts: { title?: string | null; parentID?: string | null; adopt?: boolean } = {},
  ) {
    if (opts.parentID) return

    let title = opts.title
    if (title === undefined) {
      try {
        const res = await client.session.get({ path: { id: sessionId } })
        if (res.data?.parentID) return
        title = res.data?.title
      } catch {
        return
      }
    }

    if (currentSessionId && sessionId !== currentSessionId && !opts.adopt) return
    currentSessionId = sessionId
    applyTitle(paneId, extractTmuxLabel(title), last)
  }

  if (isResumeLaunch()) {
    void client.session
      .list()
      .then((res) => {
        if (currentSessionId) return
        const root = (res.data ?? [])
          .filter((s) => !s.parentID)
          .sort((a, b) => (b.time?.updated ?? 0) - (a.time?.updated ?? 0))[0]
        if (root) return sync(root.id, { title: root.title, parentID: root.parentID, adopt: true })
      })
      .catch(() => {})
  } else {
    applyTitle(paneId, null, last)
  }

  return {
    tool: { set_session_title: setSessionTitle },
    dispose: async () => applyTitle(paneId, null, last),
    "chat.message": async (input) => {
      await sync(input.sessionID, { adopt: true })
    },
    event: async ({ event }) => {
      const type = event.type
      const props = (event as { properties?: Record<string, unknown> }).properties || {}
      const info = props.info as { id?: string; title?: string; parentID?: string } | undefined
      const sid = info?.id || (props.sessionID as string | undefined)
      if (!sid) return

      if (type === "session.created") {
        await sync(sid, { title: info?.title, parentID: info?.parentID, adopt: true })
        return
      }
      if (type === "session.updated") {
        await sync(sid, { title: info?.title, parentID: info?.parentID })
        return
      }
      if (type === "session.deleted" && sid === currentSessionId) {
        currentSessionId = null
    applyTitle(paneId, null, last, true)
      }
    },
  }
}) satisfies Plugin
