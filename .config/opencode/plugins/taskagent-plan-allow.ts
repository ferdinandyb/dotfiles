import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "taskagent-plan-allow",
  async setup(ctx) {
    await ctx.session.hook("context", (event) => {
      if (event.agent !== "plan") return
      event.system.push({
        type: "text",
        text: "<system-reminder>\nException: Read-only taskagent commands (list, info, ready, etc.) and `taskagent add ...` are allowed in Plan Mode. Other taskagent mutations (modify, done, start, stop, delete) remain forbidden.\n</system-reminder>",
      })
    })
  },
})
