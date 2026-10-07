import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "taskagent-plan-allow",
  async setup(ctx) {
    await ctx.session.hook("context", (event) => {
      if (event.agent !== "plan") return
      event.system.push({
        type: "text",
        text: "<system-reminder>\nException: `taskagent add ...` is allowed in Plan Mode. Append-only to task DB, equivalent to writing the plan file. No other taskagent subcommands.\n</system-reminder>",
      })
    })
  },
})
