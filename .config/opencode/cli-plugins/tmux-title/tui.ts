import { Plugin } from "@opencode/plugin/tui"
import { createEffect } from "solid-js"
import { spawnSync } from "node:child_process"
import { deriveSessionStatus, extractTmuxLabel, resolveTmuxPane } from "../../plugins/lib/tmux-title-label"

export default Plugin.define({
  id: "tmux-title",
  setup(ctx) {
    const pane = resolveTmuxPane()
    if (!pane) return
    let lastLabel: string | null | undefined
    let lastStatus: string | null | undefined

    const sync = (title?: string, status?: string) => {
      const label = extractTmuxLabel(title)
      const currentStatus = status || null
      if (label === lastLabel && currentStatus === lastStatus) return
      lastLabel = label
      lastStatus = currentStatus

      spawnSync(
        "tmux",
        [
          ...(label
            ? ["set-option", "-p", "-t", pane, "@opencode_title", label]
            : ["set-option", "-p", "-u", "-t", pane, "@opencode_title"]),
          ";",
          ...(currentStatus
            ? ["set-option", "-p", "-t", pane, "@opencode_status", currentStatus]
            : ["set-option", "-p", "-u", "-t", pane, "@opencode_status"]),
          ";",
          "if-shell",
          "-t",
          pane,
          "-F",
          "#{automatic-rename}",
          `set-window-option -t ${pane} automatic-rename on`,
          ";",
          "refresh-client",
          "-S",
        ],
        { stdio: "ignore" },
      )
    }

    const dispose = ctx.ui.slot({
      append: "app",
      render: () => {
        createEffect(() => {
          const route = ctx.ui.router.current()
          if (route.type !== "session") {
            sync()
            return
          }
          const rootID = ctx.data.session.root(route.sessionID)
          const session = ctx.data.session.get(rootID)
          const members = ctx.data.session.family(rootID)
          const status = deriveSessionStatus(rootID, members, ctx.data.session)
          sync(session?.title, status)
        })
        return null
      },
    })

    return () => {
      dispose()
      sync()
    }
  },
})
