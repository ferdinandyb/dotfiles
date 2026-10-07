import { Plugin } from "@opencode/plugin/tui"
import { createEffect } from "solid-js"
import { spawnSync } from "node:child_process"
import { extractTmuxLabel, resolveTmuxPane } from "../../plugins/lib/tmux-title-label"

export default Plugin.define({
  id: "tmux-title",
  setup(ctx) {
    const pane = resolveTmuxPane()
    if (!pane) return
    let last: string | null | undefined
    const sync = (title?: string) => {
      const label = extractTmuxLabel(title)
      if (label === last) return
      last = label
      spawnSync("tmux", [
        ...(label
          ? ["set-option", "-p", "-t", pane, "@opencode_title", label]
          : ["set-option", "-p", "-u", "-t", pane, "@opencode_title"]),
        ";", "if-shell", "-t", pane, "-F", "#{automatic-rename}",
        `set-window-option -t ${pane} automatic-rename on`,
      ], { stdio: "ignore" })
    }
    const dispose = ctx.ui.slot({
      append: "app",
      render: () => {
        createEffect(() => {
          const route = ctx.ui.router.current()
          const session = route.type === "session" ? ctx.data.session.get(ctx.data.session.root(route.sessionID)) : undefined
          sync(session?.title)
        })
        return null
      },
    })
    return () => { dispose(); sync() }
  },
})
