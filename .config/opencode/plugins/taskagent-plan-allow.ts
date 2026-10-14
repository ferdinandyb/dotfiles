import { Message } from "@opencode/ai"
import { Plugin } from "@opencode/plugin"

const REMINDER = "<system-reminder>\nException: Read-only taskagent commands (list, info, ready, etc.) and `taskagent add ...` are allowed in Plan Mode. Other taskagent mutations (modify, done, start, stop, delete) remain forbidden in Plan Mode.\n</system-reminder>"

export default Plugin.define({
  id: "taskagent-plan-allow",
  async setup(ctx) {
    await ctx.session.hook("context", async (event) => {
      if (event.agent !== "plan") return
      const entered = event.messages.findLastIndex((message) =>
        message.role === "user" && message.content.some((part) =>
          part.type === "text" && part.text.startsWith("<system-reminder>\nYou are in Plan mode."),
        ),
      )
      if (event.messages.slice(entered + 1).some((message) =>
        message.role === "user" && message.content.some((part) => part.type === "text" && part.text === REMINDER),
      )) return
      const at = Math.max(entered + 1, event.messages.at(-1)?.role === "user" ? event.messages.length - 1 : event.messages.length)
      event.messages.splice(at, 0, Message.user(REMINDER))
      await ctx.session.synthetic({ sessionID: event.sessionID, text: REMINDER, resume: false })
    })
  },
})
